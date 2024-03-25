import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, Button, StyleSheet, Image, ActivityIndicator, TouchableHighlight, TouchableOpacity } from 'react-native';
import { Audio } from 'expo-av';
import * as FileSystem from 'expo-file-system';
import * as Animatable from 'react-native-animatable';
import { AWS_API_KEY, GET_GAME_START_METADATA_URL } from '@env';

const Game = () => {

	// State variable for the user guess
	const [guess, setGuess] = useState('');
	
	// State variable for the metadata of the game song
	const [metadata, setMetadata] = useState({});
	
	// State variables for the audio URLs
	const [audioObjects, setAudioObjects] = useState([]);
	const [audioProgress, setAudioProgress] = useState(0);
	const [soundUrls, setSoundUrls] = useState([]);

	// Other state variables
	const [loading, setLoading] = useState(true);
	const [gameOver, setGameOver] = useState(false);
	const [didWin, setDidWin] = useState(false);
	const [numGuesses, setNumGuesses] = useState(0);

	// Hints enabled
	const [hintYear, setHintYear] = useState(false);
	const [hintGenre, setHintGenre] = useState(false);
	const [hintAlbum, setHintAlbum] = useState(false);
	const [hintArtist, setHintArtist] = useState(false);

	// Load the audio files from the server
	useEffect(() => {
		
		fetchAudioAndMetadata();

	}, []);

	const fetchAudioAndMetadata = async () => {
		try {
			// Fetch a list of possible games that can be played
			const response = await fetch(GET_GAME_START_METADATA_URL, {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json',
					'x-api-key': AWS_API_KEY,
				}
			});
			// Get the metadata of the game
			const metadata = await response.json();
			// TODO: Error handling for when there are no songs available
			// Set metadata state variable
			setMetadata(metadata);
			// Set the sound URLs (only drums for the first round)
			setSoundUrls([metadata.urls.drum_url]);
			// Enable a hint for the year
			setHintYear(true);
			// Set loading to false
			// TODO: Set loading false
			console.log(`Metadata retrieved successfully.`)
		}
		catch (err) {
			console.log(err);
		}
	}

	const playAudio = async () => {
		try {
			// Stop and unload any previous audio
			await Promise.all(audioObjects.map(soundObj => soundObj.unloadAsync()));
			// Set audio objects to an empty array (to fill again)
			setAudioObjects([]);
			setAudioProgress(0);
			// Array to hold new audio objects
			const newAudioObjects = [];
			// Go through all sound layers (that are playing) and add them to the array
			const playPromises = soundUrls.map(async (url, index) => {
				// Create a new audio object
				const { sound, status } = await Audio.Sound.createAsync(
					{ uri: url },
					{ shouldPlay: true }
				);
				// Set the playback status to the state variable
				sound.setOnPlaybackStatusUpdate((playbackStatus) => {
					if (!playbackStatus.isLoaded) {
						// Error handling here
					} else {
						if (playbackStatus.isPlaying) {
							// Get the current progress of the playback
							const progress = playbackStatus.positionMillis / playbackStatus.durationMillis;
							// Set the audio progress bar only if the progress is greater than the current progress
							if (progress > audioProgress) setAudioProgress(progress);
						}
						if (playbackStatus.didJustFinish && !playbackStatus.isLooping) {
							// Handle finish
						}
					}
				});
				// Push the audio object to the array
				newAudioObjects.push(sound);
				// Return the play promise
				return sound.playAsync();
			});
			// Use Promise.all to play all sounds at the same time
			await Promise.all(playPromises);
			// Set audio objects array
			setAudioObjects(newAudioObjects);
		}
		catch (error) {
			// Handle the error
		}
	};

	const stopAudio = async () => {
		try {
			// Stop and unload any previous audio
			await Promise.all(audioObjects.map(soundObj => soundObj.unloadAsync()));
			// Set audio objects to an empty array
			setAudioObjects([]);
			setAudioProgress(0);
		}
		catch (error) {
			// Handle the error
		}
	
	}

	const handleGuessSubmit = () => {
		// Check if the guess is correct
		if (guess.toLowerCase() === metadata.title.toLowerCase()) {
			// Set did win to true
			setDidWin(true);
			// Set game over to true
			setGameOver(true);
		}
		else {
			// Debug console
			console.log(`Guess: ${guess}, Number of guesses: ${numGuesses}`);
			// Set the guess to an empty string
			setGuess('');
			// Add another instrument to the sound URLs depending on number of guesses
			if (numGuesses === 0) {
				setSoundUrls([metadata.urls.drum_url, metadata.urls.bass_url]);
				// Enable a hint for the genre
				setHintGenre(true);
			}
			else if (numGuesses === 1) {
				setSoundUrls([metadata.urls.drum_url, metadata.urls.bass_url, metadata.urls.other_url]);
				// Enable a hint for the album
				setHintAlbum(true);
			}
			else if (numGuesses === 2) {
				setSoundUrls([metadata.urls.full_url]);
				// Enable a hint for the artist
				setHintArtist(true);
			}
			else if (numGuesses >= 3) {
				// Set game over to true
				setGameOver(true);
			}
			// Increment the number of guesses
			setNumGuesses(numGuesses + 1);
		}
	};

	return (
		<View style={styles.container}>
			{loading && <ActivityIndicator size="large" color="#0000ff" />}
			<Image
                source={{ uri: metadata.album_art_url }}
                style={styles.albumcover}
                onLoadEnd={() => setLoading(false)}
				blurRadius={15-numGuesses*4}
            />
			<View style={{flexDirection: 'row', width: '90%', height: 10, backgroundColor: '#FFF4E6'}}>
    			<View style={{flex: audioProgress, backgroundColor: '#BE9B7B'}} />
    			<View style={{flex: 1 - audioProgress, backgroundColor: '#FFF4E6'}} />
			</View>
			<View style={styles.playstopbuttoncontainer}>
				<TouchableHighlight onPress={playAudio}>
					<Image style={styles.playstopbutton} source={require("../../assets/play_button.png")}/>
				</TouchableHighlight>
				<TouchableHighlight onPress={stopAudio}>
					<Image style={styles.playstopbutton} source={require("../../assets/stop_button.png")}/>
				</TouchableHighlight>
			</View>
			<View style={styles.numguessbox}><Text style={styles.numguesstext}>Number of Guesses: {numGuesses}</Text></View>
			<View style={styles.hintcontainer}>
				<View style={styles.hintbox}>{hintYear && <Text style={styles.textfont}>Year: {metadata.year}</Text>}</View>
				<View style={styles.hintbox}>{hintGenre && <Text style={styles.textfont}>Genre: {metadata.genre}</Text>}</View>
				<View style={styles.hintbox}>{hintAlbum && <Text style={styles.textfont}>Album: {metadata.album}</Text>}</View>
				<View style={styles.hintbox}>{hintArtist && <Text style={styles.textfont}>Artist: {metadata.artist}</Text>}</View>
			</View>
			<TextInput
                style={[styles.input, styles.textfont]}
                onChangeText={setGuess}
                value={guess}
                placeholder="Enter your guess"
				placeholderTextColor="#FFF4E6"
            />
            <TouchableOpacity style={styles.guessbox} onPress={handleGuessSubmit} >
				<Text style={styles.guessfont}>Submit Guess</Text>
			</TouchableOpacity>
            {gameOver && <Text style={styles.textfont}>Game Over!</Text>}
			{didWin && <Text style={styles.textfont}>You Win!</Text>}
            
        </View>
	);
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
		backgroundColor: '#3C2F2F'
    },
    albumcover: {
        width: 300,
        height: 300,
        marginBottom: 25,
    },
	playstopbutton: {
        width: 50,
        height: 50,
		marginHorizontal: 10
    },
	playstopbuttoncontainer: {
		flexDirection: 'row',
		alignItems: 'flex-start',
		justifyContent: 'flex-start',
		marginTop: 10,
		marginBottom: 5
	},
    input: {
        borderWidth: 2,
        borderColor: '#FFF4E6',
        width: '80%',
        padding: 10,
        margin: 10,
    },
	textfont: {
		color: '#FFF4E6',
        textAlign: 'left',
        fontSize: 9,
	},
	guessbox: {
        alignItems: 'center',
		backgroundColor: '#BE9B7B',
        borderTopLeftRadius: 10,
        borderTopRightRadius: 10,
        borderBottomLeftRadius: 10,
        borderBottomRightRadius: 10,
		borderWidth: 1,
		borderColor: '#FFF4E6',
		padding: 10,
		marginTop: 5,
        marginBottom: 8,
        marginHorizontal: 25,
	},
	guessfont:{
		color: '#FFF4E6',
        textAlign: 'center',
        fontSize: 20,
	},
	hintcontainer:{
		flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
		backgroundColor: '#3C2F2F'
	},
	hintbox: {
        alignItems: 'center',
		backgroundColor: '#BE9B7B',
        borderTopLeftRadius: 10,
        borderTopRightRadius: 10,
        borderBottomLeftRadius: 10,
        borderBottomRightRadius: 10,
		borderWidth: 1,
		borderColor: '#FFF4E6',
		padding: 5,
		marginTop: 5,
        marginBottom: 5,
        marginHorizontal: 3,
	},
	numguessbox:{
		alignItems: 'center',
		backgroundColor: '#BE9B7B',
		borderTopLeftRadius: 5,
        borderTopRightRadius: 5,
        borderBottomLeftRadius: 5,
        borderBottomRightRadius: 5,
		borderWidth: 1,
		borderColor: '#FFF4E6',
		padding: 3,
		marginTop: 5,
        marginBottom: 5,
        marginHorizontal: 20
	},
	numguesstext:{
		color: '#FFF4E6',
        textAlign: 'left',
        fontSize: 15,
	}
});

export default Game;