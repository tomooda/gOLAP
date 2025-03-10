Class {
	#name : 'PlemolJPRegular',
	#superclass : 'EmbeddedFreeTypeFontDescription',
	#classInstVars : [
		'fontContents'
	],
	#category : 'Golap-UI-Fonts',
	#package : 'Golap-UI',
	#tag : 'Fonts'
}

{ #category : 'testing' }
PlemolJPRegular class >> canBeInstalled [

	^ super canBeInstalled and: [ self fontReference notNil ]
]

{ #category : 'accessing' }
PlemolJPRegular class >> fontContents [

	^ (fontContents ifNil: [
		   fontContents := self fontReference binaryReadStreamDo: #contents ])
		  copy
]

{ #category : 'accessing' }
PlemolJPRegular class >> fontReference [

	^ FileLocator workingDirectory / 'Fonts' / self originalFileName
]

{ #category : 'accessing' }
PlemolJPRegular class >> originalFileName [

	^ 'PlemolJP-Regular.ttf'
]
