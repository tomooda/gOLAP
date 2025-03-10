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

	^ (IceRepository repositoryNamed: 'gOLAP') ifNotNil: [ :repository |
		  repository location / 'resources' / 'Fonts'
		  / self originalFileName ]
]

{ #category : 'accessing' }
PlemoJPRegular class >> initialize [

	self canBeInstalled ifTrue: [
		EmbeddedFreeTypeFontInstaller registerFont: self.
		FreeTypeFontProvider current buildFamilies.
		StandardFonts setAllStandardFontsTo:
			(LogicalFont familyName: 'PlemolJP' pointSize: 10) ]
]

{ #category : 'accessing' }
PlemoJPRegular class >> originalFileName [

	^ 'PlemolJP-Regular.ttf'
]
