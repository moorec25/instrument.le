import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert, ActivityIndicator, ScrollView } from 'react-native';
import { onAuthenticate } from '../apis/auth';
import { useNavigation } from '@react-navigation/native';
import * as aw from '../apis/aws';

const ChooseSong = () => {

	const navigation = useNavigation();

	// Authentication
	const [isAuthenticated, setIsAuthenticated] = useState(false);
	const [loading, setLoading] = useState(false);
	const [userId, setUserId] = useState(null);
	const [userSongs, setUserSongs] = useState({});

	const handleClick = (index) => {
		// Ensure metadata exists
		if (!userSongs) return;
		// Switch screen with props
		navigation.navigate('PlaySeparate', { metadata: userSongs[index] });
	}

	const authenticateUser = async () => {
		// Authenticate the user
		const result = await onAuthenticate();
		// Update state
		setIsAuthenticated(result.success);
		setUserId(result.userId);
		// If the user is authenticated, retrieve songs
		if (result.success) {
			// Set loading state
			setLoading(true);
			// Load the user's metadata from AWS
			const metadata = await aw.getUserSongs(result.userId);
			// Update state
			setUserSongs(metadata);
			// Set loading state
			setLoading(false);
		}
		else {
			Alert.alert('Error', 'Failed to authenticate user. Please try again.');
		}
	}

	return(
		<View style={styles.container}>
            { 
            isAuthenticated
            ?
			<View style={styles.container}>
				{
					loading
					?
					<ActivityIndicator color='#3C2F2F' size={20} />
					:
					<ScrollView>
						{
							Object.keys(userSongs).map((_, index) => (
								<TouchableOpacity style={styles.button} key = {index} onPress = {() => handleClick(index)}>
								    <Text style={styles.textfont}>{userSongs[index].title}</Text>
								</TouchableOpacity>
							))
						}
					</ScrollView>
				}
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
	    backgroundColor: '#FFF4E6',
	},
	buttoncontainer: {
	    flexDirection: 'row',
	    alignItems: 'center',
	    justifyContent: 'center',
	},
	textfont: {
	    color: '#FFF4E6',
	    textAlign: 'left',
	    fontSize: 20,
	},
	button: {
	    alignContent: 'flex-start',
	    justifyContent: 'flex-start',
	    backgroundColor: '#4B3832',
	    minWidth: '85%',
	    padding: 10,
	    paddingHorizontal: 15,
	    marginTop: 1,
	},
	textfont:{
        color: '#FFF4E6',
        textAlign: 'center',
        fontSize: 20,
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
});

export default ChooseSong;