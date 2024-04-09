import React, { useState, useRef, useEffect } from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Audio } from 'expo-av';

const ListenSongPlayback = ({ label, url }) => {

    // State variables for the audio object
    const soundRef = useRef(null);

    // State variable for progress of audio track
    const [audioProgress, setAudioProgress] = useState(0);

	useEffect(() => {
		// Kill all audio when leaving screen
		return () => {
            stopAudio();
        };
	}, []);

    const playAudio = async () => {
		try {
            // Stop all audio
            await stopAudio();
            // Create a new audio object
			const { sound } = await Audio.Sound.createAsync(
				{ uri: url },
				{ shouldPlay: true }
			);
			// Set the playback status to the state variable
			sound.setOnPlaybackStatusUpdate((playbackStatus) => {
				if (!playbackStatus.isLoaded) {
					// Error handling here
				} 
                else {
					if (playbackStatus.isPlaying) {
						// Get the current progress of the playback
						const progress = playbackStatus.positionMillis / playbackStatus.durationMillis;
						// Set the audio progress bar only if the progress is greater than the current progress
						setAudioProgress(progress);
					}
					if (playbackStatus.didJustFinish && !playbackStatus.isLooping) {
						// Unload the audio object
						sound.unloadAsync();
                        // Set progress back to 0
                        setAudioProgress(0);
					}
				}
			});
            // Play the audio object
			await sound.playAsync();
            // Set audio ref
			soundRef.current = sound;
		}
		catch (error) {
			// Handle the error
		}
	};

    const stopAudio = async () => {
		try {
			// Stop and unload any previous audio
			await soundRef.current.stopAsync();
            await soundRef.current.unloadAsync();
			// Set audio progress to 0
			setAudioProgress(0);
		}
		catch (error) {
			// Handle the error
		}
	}
    
    return (
        <View style={styles.tracklistcontainer}>
            <View style={styles.trackcontainer}>
                <Text style={styles.trackfont}>{label}</Text>
                <View style={styles.progressBarContainer}>
    			    <View style={{flex: audioProgress, backgroundColor: '#BE9B7B'}} />
    			    <View style={{flex: 1 - audioProgress, backgroundColor: '#d3d3d3'}} />
			    </View>
                <View style={styles.buttonContainer}>
                    <TouchableOpacity onPress={playAudio}>
				    	<Image style={styles.playstopbutton} source={require("../../assets/play_button.png")}/>
				    </TouchableOpacity>
				    <TouchableOpacity onPress={stopAudio}>
				    	<Image style={styles.playstopbutton} source={require("../../assets/stop_button.png")}/>
				    </TouchableOpacity>
                </View>
            </View>
        </View>
    )
}

const styles = StyleSheet.create({
    tracklistcontainer: {
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
    },
    trackcontainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
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
        position: 'relative',
    },
    buttonContainer: {
        flexDirection: 'row',
    },
    buttonText: {
        marginLeft: 10,
    },
    trackfont: {
        color: '#4B3832',
        textAlign: 'left',
        fontSize: 15,
    },
    playstopbutton: {
        width: 30,
        height: 30,
		marginHorizontal: 10
    },
    progressBarContainer: {
        position: 'absolute',
        left: 75,
        right: 5,
        bottom: 20,
        height: 10,
        flexDirection: 'row',
        backgroundColor: '#FFF4E6',
        width: '40%'
    },
});

export default ListenSongPlayback;