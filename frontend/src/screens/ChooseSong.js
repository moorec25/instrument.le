import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

const screenMap = {
  'Add New': 'FindSeparate',
  'Separate': 'PlaySeparate',
}



const ChooseSong = ({ navigation }) => {

  const handleClick = (screen) => navigation.navigate(screen);

  return(
    <View style={styles.container}>
      <View>
          {
            Object.keys(screenMap).map((button, index) => (
                // Create a button for each item in the screenMap, mapped to the navigation function
                <TouchableOpacity style={styles.button} key = {index} onPress = {() => handleClick(screenMap[button])}>
                    <Text style={styles.textfont}>{button}</Text>
                </TouchableOpacity>
            ))
          }
      </View>
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
  }
});

export default ChooseSong;