import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { Audio } from 'expo-av';
import ListenSongPlayback from '../components/ListenSongPlayback';

const PlaySeparate = ({ route }) => {

	const { metadata } = route.params;

	return (
		<View style={styles.container}>
			<View style={styles.titlecontainer}><Text style={styles.titlefont}>{metadata.title}</Text></View>
      <View style={styles.imagecontainer}>
        {
        metadata.album_art_url
        ?
        <Image
          source={{ uri: metadata.album_art_url }}
          style={styles.albumcover}
        />
        :
        <Image
          source={require("../../assets/album_placeholder.png")}
          style={styles.albumcover}
        />
        }
      </View>
			<ListenSongPlayback label={'Bass'} url={metadata.bass_url} />
			<ListenSongPlayback label={'Drums'} url={metadata.drums_url} />
			<ListenSongPlayback label={'Vocals'} url={metadata.vocals_url} />
			<ListenSongPlayback label={'Other'} url={metadata.other_url} />
			<View style={styles.yeargenrecontainer}>
				<View style={styles.metadatacont}><Text style={styles.textfont}>Year: {metadata.year}</Text></View>
				<View style={styles.metadatacont}><Text style={styles.textfont}>Genre: {metadata.genre}</Text></View>
			</View>
			<View style={styles.metadatacont}><Text style={styles.textfont}>Album: {metadata.album}</Text></View>
			<View style={styles.metadata4}><Text style={styles.textfont}>Artist: {metadata.artist}</Text></View>
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
  imagecontainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  yeargenrecontainer:{
	flexDirection: 'row',
	alignItems: 'center',
	justifyContent: 'center',
  },
  albumcover: {
	width: 200,
	height: 200,
	marginBottom: 10,
	borderRadius: 5,
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
    marginBottom: 10,
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
  data: {
	flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  metadatacont: {
	alignItems: 'center',
	backgroundColor: '#FFF4E6',
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
  metadata4: {
	alignItems: 'center',
	backgroundColor: '#FFF4E6',
	borderTopLeftRadius: 10,
	borderTopRightRadius: 10,
	borderBottomLeftRadius: 10,
	borderBottomRightRadius: 10,
	borderWidth: 1,
	borderColor: '#FFF4E6',
	padding: 5,
	marginTop: 5,
	marginBottom: 10,
	marginHorizontal: 3,
  },
  titlefont: {
    color: '#4B3832',
    textAlign: 'center',
    fontSize: 40,
  },
  textfont: {
    color: '#4B3832',
    textAlign: 'center',
    fontSize: 15,
  }
});


export default PlaySeparate;