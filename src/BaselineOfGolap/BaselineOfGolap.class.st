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
			baseline: 'ObjCBridge'
			with: [ spec repository: 'github://tesonep/objcbridge/src' ].
		spec
			baseline: 'PharoApplicationGenerator'
			with: [
			spec repository: 'github://testonep/PharoApplicationGenerator/src' ].
		spec
			baseline: 'HiDeHo'
			with: [ spec repository: 'github://tomooda/HiDeHo:main/src' ].
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
			package: 'Golap-Application'
			with: [
			spec requires: #( 'ObjCBridge' 'PharoApplicationGenerator' ) ].
		spec
			package: 'Golap-Networking'
			with: [ spec requires: #( 'DataFrame' ) ].
		spec
			package: 'Golap-Query'
			with: [ spec requires: #( 'PetitParser2Core' ) ].
		spec package: 'Golap-UI' with: [
			spec requires:
				#( 'Golap-Clustering' 'Golap-Models' 'Golap-Networking'
				   'Golap-Query' 'HiDeHo' 'DataFrame' 'Xenq' ) ].
		spec
			package: 'Golap-Models'
			with: [ spec requires: #( 'DataFrame' 'Golap-Clustering' ) ].
		spec package: 'Golap-Clustering' with: [ spec requires: #(  ) ].
		spec
			group: 'Core'
			with:
				#( 'Golap-Models' 'Golap-UI' 'Golap-Query' 'Golap-Networking'
				   'Golap-Clustering' 'Golap-Application' );
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
