Class {
	#name : 'BaselineOfGolap',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGolap',
	#package : 'BaselineOfGolap'
}

{ #category : 'baseline' }
BaselineOfGolap >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'DataFrame'
			with: [ spec repository: 'github://PolyMathOrg/DataFrame/src' ].
		spec
			baseline: 'PetitParser2Core'
			with: [ spec repository: 'github://kursjan/petitparser2/' ].
		spec
			baseline: 'Xenq'
			with: [ spec repository: 'github://tomooda/Xenq:main/src' ].
		spec
			package: 'Golap-Networking'
			with: [ spec requires: #( 'DataFrame' ) ].
		spec
			package: 'Golap-Query'
			with: [ spec requires: #( 'Golap-Networking' 'PetitParser2Core' ) ].
		spec package: 'Golap-UI' with: [
			spec requires:
				#( 'Golap-Models' 'Golap-Networking' 'DataFrame' 'Xenq' ) ].
		spec
			package: 'Golap-Models'
			with: [ spec requires: #( 'DataFrame' ) ].
		spec
			package: 'Golap-Clustering'
			with: [ spec requires: #( 'Golap-Models' ) ].
		spec
			group: 'Core'
			with:
				#( 'Golap-Models' 'Golap-UI' 'Golap-Query' 'Golap-Networking'
				   'Golap-Clustering' );
			group: 'default' with: #( 'Core' ) ]
]

{ #category : 'utilities' }
BaselineOfGolap >> installDesktopLogo [

	<script: 'BaselineOfGolap new installDesktopLogo'>
	| backgroundImage response |
	backgroundImage := FileLocator localDirectory / 'gOLAP'
	                   / 'gOLAP-logo.png'.
	PharoLightTheme beCurrent.
	response := ZnClient new
		            url:
			            'https://github.com/tomooda/gOLAP/raw/main/resources/gOLAP-logo.png';
		            get;
		            response.
	(response isSuccess and: [ response entity contentType sub = 'png' ])
		ifTrue: [
			backgroundImage parent ensureCreateDirectory.
			backgroundImage ensureDelete.
			backgroundImage binaryWriteStreamDo: [ :writeStream |
				response entity writeOn: writeStream ].
			PolymorphSystemSettings desktopLogoFileName: ''.
			PolymorphSystemSettings desktopLogoFileName:
				backgroundImage fullName ]
]
