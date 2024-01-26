import React from 'react';
import { View, Text, TouchableOpacity, Image, StyleSheet } from 'react-native';

// Map of buttons to the screen they navigate to
const screenMap = {
    'Play':     'Game',
    'Separate': 'FindSeparate',
    'Listen':   'ChooseSong'
}

const Home = ({ navigation }) => {

    // Function to handle navigation to different screens
    const handleClick = (screen) => navigation.navigate(screen);

    return (
        <View>
            <View>
                {
                    Object.keys(screenMap).map((button, index) => (
                        // Create a button for each item in the screenMap, mapped to the navigation function
                        <TouchableOpacity key = {index} onPress = {() => handleClick(screenMap[button])}>
                            <Text>{button}</Text>
                        </TouchableOpacity>
                    ))
                }
            </View>
        </View>
    );
}

export default Home;