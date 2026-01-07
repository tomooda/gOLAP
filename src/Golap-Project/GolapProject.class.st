Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'accessing' }
GolapProject class >> golapDirectory [

	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'accessing' }
GolapProject class >> illegalCharactersInFilenames [

	^ '<>:"/\|?*' asSet
]

{ #category : 'accessing' }
GolapProject class >> projectFileExtention [

	'gporj'
]

{ #category : 'enumerating' }
GolapProject class >> projectFilesDo: aBlock [

	(self golapDirectory filesMatching: '*.' , self projectFileExtention)
		do: aBlock
]

{ #category : 'enumerating' }
GolapProject >> golapsDo: aBlock [

	Golap allInstancesDo: [ :golap |
			(golap window ifNotNil: #isOpen ifNil: [ false ]) ifTrue: [
				aBlock value: golap ] ]
]

{ #category : 'enumerating' }
GolapProject >> golapsDo: aBlock separatedBy: anotherBlock [

	| firstTime |
	firstTime := true.
	self golapsDo: [ :golap |
			firstTime
				ifTrue: [ firstTime := false ]
				ifFalse: [ anotherBlock value ].
			aBlock value: golap ]
]

{ #category : 'accessing' }
GolapProject >> name [

	^ name
]

{ #category : 'accessing' }
GolapProject >> name: aString [

	name := aString
]

{ #category : 'operations' }
GolapProject >> saveInto: aFileReference [

	aFileReference writeStreamDo: [ :stream |
			| writer |
			writer := NeoJSONWriter on: (stream
					           truncate;
					           yourself).
			stream nextPut: $[.
			self
				golapsDo: [ :golap | writer nextPut: golap asJSON ]
				separatedBy: [ stream nextPut: $, ].
			stream nextPut: $] ]
]
