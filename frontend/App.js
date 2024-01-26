import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Import screens
import Home from './src/screens/Home';
import Game from './src/screens/Game';
import ChooseSong from './src/screens/ChooseSong';
import PlaySeparate from './src/screens/PlaySeparate';
import FindSeparate from './src/screens/FindSeparate';
import { Button } from 'react-native';

const Stack = createNativeStackNavigator();

const App = () => {
  return (
    <NavigationContainer>
    	<Stack.Navigator
    	  screenOptions={({ navigation }) => ({
    	    headerLeft: () => (
    	      <Button
    	        onPress={() => navigation.goBack()}
    	        title="Back"
    	        color="#000"
    	      />
    	    )
    	    })}
    	>
    	  <Stack.Screen name="Home" component={Home} />
    	  <Stack.Screen name="Game" component={Game} />
    	  <Stack.Screen name="ChooseSong" component={ChooseSong} />
    	  <Stack.Screen name="PlaySeparate" component={PlaySeparate} />
    	  <Stack.Screen name="FindSeparate" component={FindSeparate} />
    	</Stack.Navigator>
    </NavigationContainer>
  );
};

export default App;
