import React, { useState, useEffect, useRef } from 'react';
import { View, Text, TextInput, StyleSheet, Image, TouchableHighlight, TouchableOpacity } from 'react-native';
import { Audio } from 'expo-av';
import { AWS_API_KEY, GET_GAME_START_METADATA_URL } from '@env';
import { LoadingScreen } from './LoadingScreen';
import { Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import ListenSongPlayback from '../components/ListenSongPlayback';

const Game = () => {

	const navigation = useNavigation();

	// State variable for the user guess
	const [guess, setGuess] = useState('');
	
	// State variable for the metadata of the game song
	const [metadata, setMetadata] = useState({});
	
	// State variables for the audio URLs
	const audioObjectsRef = useRef([]);
	const [audioProgress, setAudioProgress] = useState(0);
	const [soundUrls, setSoundUrls] = useState([]);

	// Other state variables
	const [timeLoading, setTimeLoading] = useState(true);
	const [metadataLoading, setMetadataLoading] = useState(true);
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
		// Get the game metadata
		fetchAudioAndMetadata();
		// After 2 seconds set timeLoading to false
		setTimeout(() => setTimeLoading(false), 1500);
		// Kill all audio when leaving screen
		const unsubscribe = navigation.addListener('beforeRemove', (e) => {
			// Prevent default behavior of leaving the screen
			e.preventDefault();
			// Call your stopAudio function
			stopAudio().then(() => {
			  // After stopping audio, continue with the navigation
			  navigation.dispatch(e.data.action);
			});
		});
		return unsubscribe;
	}, [navigation]);

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
			console.log(metadata)
			// If there is no metadata, there is no songs available for the game
			if (!metadata.urls) {
				// Give alert to tell user they won
				Alert.alert('Error', 'There are no songs available for the game. Please try again later.');
				// Debug message
				console.error('No metadata found for the game.');
			}
			else {
				// Set metadata state variable
				setMetadata(metadata);
				// Set the sound URLs (only drums for the first round)
				setSoundUrls([metadata.urls.drum_url]);
				// Enable a hint for the year
				setHintYear(true);
				// Set loading to false
				setMetadataLoading(false);
				// Debug message
				console.log(`Metadata retrieved successfully.`);
			}
		}
		catch (err) {
			// Give alert to tell user they won
			Alert.alert('Error', 'There was an error loading the game, please try again...');
			// Debug print
			console.error(err);
		}
	}

	const playAudio = async () => {
		try {
			// Stop and unload any previous audio
			await stopAudio();
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
							// Unload the audio object
							sound.unloadAsync();
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
			audioObjectsRef.current = [...newAudioObjects];
		}
		catch (error) {
			// Handle the error
		}
	};

	const stopAudio = async () => {
		try {
			// Stop all audio objects
			await Promise.all(audioObjectsRef.current.map(soundObj => soundObj.stopAsync()));
			await Promise.all(audioObjectsRef.current.map(soundObj => soundObj.unloadAsync()));
			// Reset the audio objects
			setAudioProgress(0);
			audioObjectsRef.current = [];
		} catch (error) {
			// Handle the error
		}
	};

	const handleGuessSubmit = () => {
		// Stop all audio
		stopAudio();
		// Check if the guess is correct
		if (guess.toLowerCase() === metadata.title.toLowerCase()) {
			// Set did win to true
			setDidWin(true);
			// Set game over to true
			setGameOver(true);
			// Give alert to tell user they won
			Alert.alert('You Win!', 'Congratulations! You have guessed the song correctly.');
		}
		else {
			// Debug console
			console.log(`Guess: ${guess}, Remaining Guesses: ${4 - numGuesses}`);
			// Set the guess to an empty string
			setGuess('');
			// Add another instrument to the sound URLs depending on number of guesses
			if (numGuesses === 0) {
				setSoundUrls([metadata.urls.layer2_url]);
				// Enable a hint for the genre
				setHintGenre(true);
			}
			else if (numGuesses === 1) {
				setSoundUrls([metadata.urls.layer3_url]);
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
				// Give alert to tell user they lost
				Alert.alert('Game Over', 'You have run out of guesses. Please try again.');
			}
			// Increment the number of guesses
			setNumGuesses(numGuesses + 1);
		}
	};

	// If the metadata is still loading, show loading screen
	if (timeLoading || metadataLoading) {
		return <LoadingScreen />;		
	}

	return (
		<View style={styles.container}>
			{
				metadata.album_art_url
				?
				<Image
                	source={{ uri: metadata.album_art_url }}
                	style={styles.albumcover}
					blurRadius={15-numGuesses*4}
            	/>
				:
				<Image
					source={require("../../assets/album_placeholder.png")}
					style={styles.albumcover}
				/>
			}
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
			<View style={styles.numguessbox}><Text style={styles.numguesstext}>Remaining Guesses: {4 - numGuesses}</Text></View>
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
		borderRadius: 25,
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