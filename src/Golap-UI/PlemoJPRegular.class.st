Class {
	#name : 'PlemoJPRegular',
	#superclass : 'EmbeddedFreeTypeFontDescription',
	#classInstVars : [
		'fontContents'
	],
	#category : 'Golap-UI-Fonts',
	#package : 'Golap-UI',
	#tag : 'Fonts'
}

{ #category : 'testing' }
PlemoJPRegular class >> canBeInstalled [

	^ super canBeInstalled and: [ self fontReference notNil ]
]

{ #category : 'accessing' }
PlemoJPRegular class >> fontContents [

	^ (fontContents ifNil: [
		   fontContents := self fontReference binaryReadStreamDo: #contents ])
		  copy
]

{ #category : 'accessing' }
PlemoJPRegular class >> fontReference [

	^ FileLocator workingDirectory / 'Fonts' / self originalFileName
]

{ #category : 'accessing' }
PlemoJPRegular class >> originalFileName [

	^ 'PlemolJP-Regular.ttf'
]
