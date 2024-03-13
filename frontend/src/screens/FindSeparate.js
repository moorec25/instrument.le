import React, { useState, useEffect } from 'react';
import { Button, View, Text, TextInput , Alert, StyleSheet, TouchableOpacity } from 'react-native';
import * as DocumentPicker from 'expo-document-picker';
import * as Device from 'expo-device';
import * as aws from '../apis/aws';

const FindSeparate = () => {

    // State to store the file
    const [file, setFile] = useState(null);
    // State to store the key of the AWS S3 bucket
    const [key, setKey] = useState(null);
    // State to store the presigned URL of the AWS S3 bucket
    const [url, setUrl] = useState(null);
    // State to store metadata for the song
    const [songName, setSongName] = useState('');
    const [artistName, setArtistName] = useState('');
    const [albumName, setAlbumName] = useState('');
    const [releaseYear, setReleaseYear] = useState('');
    const [genre, setGenre] = useState('');

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
        // Get the presigned URL
        const res = await aws.getPresignedS3Url();
        // Check if the presigned URL is valid
        if (res && res.url) {
            // Upload the file to S3
            const fileRes = await aws.uploadFileToS3(res.url, file);
            // Check if the file was uploaded successfully
            if (fileRes) {
                // TODO: Get the unique ID of this device
                // If the file was uploaded successfully, upload the metadata
                const metaRes = await aws.uploadMetadataToDb(res.key, songName, albumName, genre, artistName, releaseYear);
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
    }

    return (
        <View style={styles.container}>
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
            <View style={styles.filecontainer}>
                <TouchableOpacity style={styles.button} onPress={selectFile}>
                    <Text style={styles.textfont}>Select File</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.button} onPress={uploadFile} disabled={!file || !songName || !artistName || !albumName || !releaseYear || !genre}>
                    <Text style={styles.textfont}>Upload File</Text>
                </TouchableOpacity>
            </View>
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
    filecontainer: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
    },
    input: {
        borderWidth: 2,
        borderColor: '#4B3832',
        height: 40,
        width: '80%',
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
    }
});

export default FindSeparate;