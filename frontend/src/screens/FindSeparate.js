import React, { useState, useMemo } from 'react';
import { View, Text, TextInput, Alert, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { onAuthenticate } from '../apis/auth';
import * as DocumentPicker from 'expo-document-picker';
import * as aws from '../apis/aws';

const FindSeparate = () => {

    // State to store the file
    const [file, setFile] = useState(null);
    const [fileName, setFileName] = useState(null);
    // State to store metadata for the song
    const [songName, setSongName] = useState('');
    const [artistName, setArtistName] = useState('');
    const [albumName, setAlbumName] = useState('');
    const [releaseYear, setReleaseYear] = useState('');
    const [genre, setGenre] = useState('');
    const [isLoading, setLoading] = useState(false);
    // Authentication
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [userId, setUserId] = useState(null);

    // Boolean to check if the user can submit the form
    const fieldsMissing = useMemo(() => {
        return !file || !songName || !artistName || !albumName || !releaseYear || !genre;
    }, [file, songName, artistName, albumName, releaseYear, genre]);

    // Function to authenticate the user
    const authenticateUser = async () => {
        // Authenticate the user
        const result = await onAuthenticate();
        // Update state
        setIsAuthenticated(result.success);
        setUserId(result.userId);
    }

    const selectFile = async () => {
        try {
            // Open the file picker on the user's device
            const res = await DocumentPicker.getDocumentAsync({ type: 'audio/*' });
            // Guard clause to check if the user cancelled the picker
            if (res.canceled || !res.assets[0]) return;
            // Convert the file URI into a blob to be uploaded
            let blob = await fetch(res.assets[0].uri).then(r => r.blob());
            // Set the file state
            setFile(blob);
            setFileName(res.assets[0].name);
        }
        catch (err) {
            if (DocumentPicker.isCancel(err)) {
                // User cancelled the picker
            }
            else {
                console.error(err);
                Alert.alert('Error', 'Failed to pick an audio file. Please try again.');
            }
        }
    }

    const uploadFile = async () => {
        // Ensure the user has filled out all the fields
        if (fieldsMissing) return;
        // Ensure the user is authenticated
        if (!isAuthenticated) return;
        // Ensure the button is not loading
        if (isLoading) return;
        // Set the loading state to true
        setLoading(true);
        // Get the presigned URL
        const res = await aws.getPresignedS3Url();
        // Check if the presigned URL is valid
        if (res && res.url) {
            // Upload the file to S3
            const fileRes = await aws.uploadFileToS3(res.url, file);
            // Check if the file was uploaded successfully
            if (fileRes) {
                // If the file was uploaded successfully, upload the metadata
                const metaRes = await aws.uploadMetadataToDb(res.key, userId, songName, albumName, genre, artistName, releaseYear);
                // Check if the metadata was uploaded successfully
                if (metaRes) {
                    Alert.alert('Success', 'File uploaded successfully');
                }
                else {
                    Alert.alert('Error', 'Failed to upload metadata. Please try again.');
                }
            }
            else {
                Alert.alert('Error', 'Failed to upload file. Please try again.');
            }
        }
        // Reset states to empty
        setSongName('');
        setArtistName('');
        setAlbumName('');
        setReleaseYear('');
        setGenre('');
        // Set loading to false
        setLoading(false);
    }

    return (
        <View style={styles.container}>
            { 
            isAuthenticated
            ?
            <View>
                <Text style={[styles.textfont, { paddingBottom: 20}]}>Enter Song Details:</Text>
                <TextInput
                    placeholder="Song Name"
                    value={songName}
                    onChangeText={setSongName}
                    placeholderTextColor= '#4B3832'
                    style={styles.input}
                />
                <TextInput
                    placeholder="Artist Name"
                    value={artistName}
                    onChangeText={setArtistName}
                    placeholderTextColor= '#4B3832'
                    style={styles.input}
                />
                <TextInput
                    placeholder="Album Name"
                    value={albumName}
                    onChangeText={setAlbumName}
                    placeholderTextColor= '#4B3832'
                    style={styles.input}
                />
                <TextInput
                    placeholder="Release Year"
                    value={releaseYear}
                    onChangeText={setReleaseYear}
                    keyboardType="numeric"
                    placeholderTextColor= '#4B3832'
                    style={styles.input}
                />
                <TextInput
                    placeholder="Genre"
                    value={genre}
                    onChangeText={setGenre}
                    placeholderTextColor= '#4B3832'
                    style={styles.input}
                />
                <View>
                    <View>
                        <View style={[styles.filecontainer, { paddingTop: 20, paddingBottom: 20 }]}>
                            <Text style={styles.textfont}>{fileName ? `Selected File: ${fileName}` : 'No file selected...'}</Text>
                        </View>
                        <View style={styles.filecontainer}>
                            <TouchableOpacity style={styles.button} onPress={selectFile}>
                                <Text style={styles.textfont}>Select File</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={[styles.button, fieldsMissing ? styles.buttonopaque : {}]} onPress={uploadFile} disabled={fieldsMissing}>
                                {
                                    isLoading 
                                    ? 
                                    <ActivityIndicator color="#FFF" /> 
                                    : 
                                    <Text style={styles.textfont}>Upload File</Text>
                                }
                            </TouchableOpacity>
                        </View>
                    </View>
                </View>
            </View>
            :
            <View>
                <TouchableOpacity style={styles.loginbutton} onPress={authenticateUser}>
                    <Text style={styles.textfont}>Authenticate</Text>
                </TouchableOpacity>
            </View>
            }
        </View>
    )   
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
		backgroundColor: '#BE9B7B'
    },
    inputcontainer: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    filecontainer: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
    },
    input: {
        borderWidth: 2,
        borderColor: '#4B3832',
        height: 40,
        minWidth: '80%',
        padding: 10,
        marginBottom: 12,
    },
    textfont:{
        color: '#FFF4E6',
        textAlign: 'center',
        fontSize: 20,
    },
    button:{
        alignItems: 'center',
		backgroundColor: '#4B3832',
        borderTopLeftRadius: 10,
        borderTopRightRadius: 10,
        borderBottomLeftRadius: 10,
        borderBottomRightRadius: 10,
		borderWidth: 2,
		borderColor: '#FFF4E6',
		padding: 10,
		marginTop: 5,
        marginHorizontal: 15,
        minWidth: 120,
        minHeight: 50
    },
    loginbutton: {
        alignContent: 'flex-start',
        justifyContent: 'flex-start',
        backgroundColor: '#4B3832',
        minWidth: '85%',
        padding: 10,
        paddingHorizontal: 15,
        marginTop: 1,
        borderTopLeftRadius: 10,
        borderTopRightRadius: 10,
        borderBottomLeftRadius: 10,
        borderBottomRightRadius: 10,
    },
    buttonopaque: {
		backgroundColor: '#BE9B7B',
    }
});

export default FindSeparate;