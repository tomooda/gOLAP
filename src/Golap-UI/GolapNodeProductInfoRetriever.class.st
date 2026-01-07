Class {
	#name : 'GolapNodeProductInfoRetriever',
	#superclass : 'GolapItemInfoRetriever',
	#instVars : [
		'photoUrlColumn',
		'availableColumns'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapNodeProductInfoRetriever class >> photoUrlColumn: aString availableColumns: anArrayOfString [

	^ self new
		  photoUrlColumn: aString;
		  availableColumns: anArrayOfString;
		  yourself
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever class >> tag [

	^ 'node'
]

{ #category : 'snapshot' }
GolapNodeProductInfoRetriever >> asJSON [

	| json |
	json := super asJSON.
	availableColumns ifNotNil: [
		json at: 'avaiableColumns' put: availableColumns ].
	photoUrlColumn ifNotNil: [
		json at: 'photoUrlColumn' put: photoUrlColumn ].
	^ json
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> availableColumns [

	^ availableColumns
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> availableColumns: anArrayOfString [

	availableColumns := anArrayOfString
]

{ #category : 'snapshot' }
GolapNodeProductInfoRetriever >> fromJSON: aDictionary [

	aDictionary
		at: 'avaiableColumns'
		ifPresent: [ :array | availableColumns := array ];
		at: 'photoUrlColumn'
		ifPresent: [ :string | photoUrlColumn := string ].
	super fromJSON: aDictionary
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> photoUrlColumn [

	^ photoUrlColumn
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> photoUrlColumn: aString [

	photoUrlColumn := aString
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> productDataFor: aGolapNode [

	^ aGolapNode data associations
]
