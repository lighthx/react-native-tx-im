import * as React from 'react';
import { StyleSheet, View, Text } from 'react-native';
import {init} from 'react-native-tx-im';
import { useEffect } from 'react';

export default function App() {
    useEffect(()=>{
       init("333").then()
    },[])

  return (
    <View style={styles.container}>
      <Text>Result</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
