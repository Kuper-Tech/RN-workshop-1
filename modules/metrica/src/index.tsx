import {NativeModules} from 'react-native';

const {Metrica} = NativeModules;

console.log('Metrica', Metrica);

export function activate(apiKey: string) {
  Metrica.activate(apiKey);
}

export function reportEvent(eventName: string, params: Object | null = null) {
  Metrica.reportEvent(eventName, params);
}
