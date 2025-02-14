Class {
	#name : 'GolapQueryStorage',
	#superclass : 'HiDeStorage',
	#instVars : [
		'url'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'operations-chronicle' }
GolapQueryStorage >> chronicleAt: aString ifAbsent: errorBlock [

	^ chronicle
		  at: aString
		  ifAbsent: errorBlock
]

{ #category : 'operations-chronicle' }
GolapQueryStorage >> chronicleMetadataDo: aBlock [

	url ifNil: [ super chronicleMetadataDo: aBlock ] ifNotNil: [
		super chronicleMetadataDo: [ :metadata |
			url = (metadata at: 'url' ifAbsent: [ nil ]) ifTrue: [
				aBlock value: metadata ] ] ]
]

{ #category : 'operations-chronicle' }
GolapQueryStorage >> chronicleSuchThat: aBlock [

	| payloads |
	payloads := chronicle values select: [ :payload |
		            aBlock value: payload hideMetadata ].
	^ payloads asSortedCollection: [ :newer :older |
		  older hideMetadata timestamp <= newer hideMetadata timestamp ]
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
