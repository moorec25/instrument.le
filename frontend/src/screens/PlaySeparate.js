import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, Button, StyleSheet, Image, ActivityIndicator, TouchableHighlight, TouchableOpacity } from 'react-native';
import { Audio } from 'expo-av';
import { AWS_API_KEY, GET_GAME_START_METADATA_URL } from '@env';

const PlaySeparate = () => {

  // State variable for the metadata of the game song
	const [metadata, setMetadata] = useState({});
	
	// State variables for the audio URLs
	const [audioObjects, setAudioObjects] = useState([]);
	const [audioProgress, setAudioProgress] = useState(0);
	const [soundUrls, setSoundUrls] = useState([]);


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
  
  
  return (
    <View style={styles.container}>
      <View style={styles.titlecontainer}><Text style={styles.titlefont}>Song Title</Text></View>
      <View style={styles.tracklistcontainer}>
        <View style={styles.trackcontainer}><Text style={styles.trackfont}>Vocals</Text></View>
        <View style={styles.trackcontainer}><Text style={styles.trackfont}>Bass</Text></View>
        <View style={styles.trackcontainer}><Text style={styles.trackfont}>Drums</Text></View>
        <View style={styles.trackcontainer}><Text style={styles.trackfont}>Other</Text></View>
      </View>
    </View>
  )
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#4B3832',
  },
  tracklistcontainer: {
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  titlecontainer: {
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#FFF4E6',
    padding: 20,
    borderTopLeftRadius: 10,
    borderTopRightRadius: 10,
    borderBottomLeftRadius: 10,
    borderBottomRightRadius: 10,
    marginBottom: 15,
  },
  trackcontainer: {
    alignSelf: 'flex-start',
    backgroundColor: '#FFF4E6',
    minWidth: '90%',
    paddingVertical: 10,
    paddingHorizontal: 10,
    borderTopLeftRadius: 10,
    borderTopRightRadius: 10,
    borderBottomLeftRadius: 10,
    borderBottomRightRadius: 10,
    marginBottom: 5,
  },
  titlefont: {
    color: '#4B3832',
    textAlign: 'center',
    fontSize: 50,
  },
  trackfont: {
    color: '#4B3832',
    textAlign: 'left',
    fontSize: 15,
  }
});


export default PlaySeparate;