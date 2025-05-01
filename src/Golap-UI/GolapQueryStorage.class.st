Class {
	#name : 'GolapQueryStorage',
	#superclass : 'HiDeStorage',
	#instVars : [
		'url'
	],
	#classInstVars : [
		'forQuery'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'instance creation' }
GolapQueryStorage class >> forQuery [

	^ forQuery ifNil: [
		  forQuery := self on: self golapDirectory / 'Queries' ]
]

{ #category : 'accessing' }
GolapQueryStorage class >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'operations-chronicle' }
GolapQueryStorage >> chronicleMetadataDo: aBlock [

	url ifNil: [ super chronicleMetadataDo: aBlock ] ifNotNil: [
		super chronicleMetadataDo: [ :metadata |
			url = (metadata at: 'url' ifAbsent: [ nil ]) ifTrue: [
				aBlock value: metadata ] ] ]
]

{ #category : 'class access' }
GolapQueryStorage >> payloadClassFor: aHiDeMetadata [

	^ GolapQueryRecord
]

{ #category : 'accessing' }
GolapQueryStorage >> url [

	^ url
]

{ #category : 'accessing' }
GolapQueryStorage >> url: aString [

	url := aString.
	self loadChronicle
]
