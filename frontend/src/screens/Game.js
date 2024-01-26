import React, { useState, useEffect } from 'react';
import { View, TextInput, Button, StyleSheet, Image, ActivityIndicator } from 'react-native';
import { Audio } from 'expo-av';
import * as FileSystem from 'expo-file-system';
import * as Animatable from 'react-native-animatable';

const Game = () => {

	// State variables
	const [guess, setGuess] = useState('');
	const [feedback, setFeedback] = useState('');
	const [gameOver, setGameOver] = useState(false);
	const [metadata, setMetadata] = useState({});
	const [localFiles, setLocalFiles] = useState({});
	const [loading, setLoading] = useState(true);
    const [sound, setSound] = useState(null);

	// Load the audio files from the server
	useEffect(() => {
		
		fetchAudioAndMetadata();

	}, []);

	const downloadAndSaveFile = async (url, filename) => {
		try {
			// Create the URI where this file will be saved to
			const uri = `${FileSystem.documentDirectory}${filename}`;
			// Create the download resumable object
			const downloadResumable = FileSystem.createDownloadResumable(
				url,
				uri
			);
			// Download the file
			const { uri: localUri } = await downloadResumable.downloadAsync();
			// Log the location of the file
			console.log(`Finished downloading to ${localUri}`);
			// Return the URI of the file
			return localUri;
		} catch (e) {
			console.error(e);
		}
	}

	const fetchAudioAndMetadata = async () => {
		try {
			const response = await fetch('http://192.168.0.10:3000/startGame');
			// Get the metadata of the game
			let metadata = await response.json();
			// Set metadata state variable
			setMetadata(metadata);
			// Local variable to hold the local files
			let localFiles = {};
			// For each file the metadata provides, retrieve audio file
			metadata.files.forEach(async (file) => {
				// Download the file and save it to the local filesystem
				let localUri = await downloadAndSaveFile(`http://192.168.0.10:3000/audio/${metadata.songId}/${file}`, file);
				// Save the local URI to the localFiles state variable
				localFiles[file] = localUri;
			});
			// Set the localFiles state variable
			setLocalFiles(localFiles);
		}
		catch (err) {
			console.log(err);
		}
	}

	const playAudio = async () => {
		console.log(localFiles);
		try {
			const soundObject = new Audio.Sound();
			await soundObject.loadAsync({ uri: localFiles['drums.wav'] });
			await soundObject.playAsync();
			//await soundObject.unloadAsync();
			// Your logic when the playback is finished
		} catch (error) {
			// Handle the error
		}
	};

	const handleGuessSubmit = async () => {
		



	};

	return (
		<View style={styles.container}>
			{loading && <ActivityIndicator size="large" color="#0000ff" />}
			<Image
                source={{ uri: metadata.albumCover }}
                style={styles.image}
                onLoadEnd={() => setLoading(false)}
            />
			<Button title="Play Sound" onPress={playAudio} />
            <TextInput
                style={styles.input}
                onChangeText={setGuess}
                value={guess}
                placeholder="Enter your guess"
            />
            <Button title="Submit Guess" onPress={handleGuessSubmit} />
            <Animatable.Text animation="fadeIn">{feedback}</Animatable.Text>
            {gameOver && <Text>Game Over!</Text>}
            {/* Audio player component */}
        </View>
	);
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    image: {
        width: 200,
        height: 200,
        marginBottom: 20,
    },
    input: {
        borderWidth: 1,
        borderColor: 'gray',
        width: '80%',
        padding: 10,
        margin: 10,
    },
});

export default Game;