import React from 'react';
import { View, Text, TextInput, Button, StyleSheet, Image, ActivityIndicator, TouchableHighlight, TouchableOpacity } from 'react-native';
import { Audio } from 'expo-av';
import ListenSongPlayback from '../components/ListenSongPlayback';

const PlaySeparate = ({ route }) => {

	const { metadata } = route.params;

	return (
		<View style={styles.container}>
			<View style={styles.titlecontainer}><Text style={styles.titlefont}>{metadata.title}</Text></View>
			<ListenSongPlayback label={'Bass'} url={metadata.bass_url} />
			<ListenSongPlayback label={'Drums'} url={metadata.drums_url} />
			<ListenSongPlayback label={'Vocals'} url={metadata.vocals_url} />
			<ListenSongPlayback label={'Other'} url={metadata.other_url} />
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