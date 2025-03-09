Class {
	#name : 'GolapCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'Golap-Application',
	#package : 'Golap-Application'
}

{ #category : 'accessing' }
GolapCommandLineHandler class >> commandName [

	^ 'gOLAP'
]

{ #category : 'utilities' }
GolapCommandLineHandler class >> generateMacOS [

	<script: 'GolapCommandLineHandler generateMacOS'>
	AppGeneratorOSXGenerator new
		properties: {
				(#AppName -> 'gOLAP').
				(#InfoString -> 'A client for gOLAP server').
				(#BundleIdentifier -> 'com.github.tomooda.gOLAP').
				(#ShortVersion -> '0.9.0').
				(#DisplayName -> 'gOLAP').
				(#IconSetFile -> (IceRepository repositoryNamed: 'gOLAP') location
				 / 'resources' / 'gOLAP.icns').
				(#CommandLineHandler -> 'appGeneratorExample').
				(#CompanyName -> 'gOLAP project') } asDictionary;
		outputDirectory: FileLocator home / 'src' / 'gOLAP';
		"addExternalDirectory: FileLocator workingDirectory / 'Fonts';"
			generate
]

{ #category : 'activation' }
GolapCommandLineHandler >> activate [
]
