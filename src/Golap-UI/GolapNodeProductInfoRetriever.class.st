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
		  availableColumns: anArrayOfString;
		  photoUrlColumn: aString;
		  yourself
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever class >> tag [

	^ 'node'
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> attributeNames [

	^ self availableColumns
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> availableColumns [

	^ availableColumns
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> availableColumns: anArrayOfString [

	availableColumns := anArrayOfString
]

{ #category : 'operations' }
GolapNodeProductInfoRetriever >> canFlushProductDataCache [

	^ false
]

{ #category : 'operations' }
GolapNodeProductInfoRetriever >> flushProductDataCache [

	
]

{ #category : 'instance creation' }
GolapNodeProductInfoRetriever >> newRetrieveApiClient [

	^ nil
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> photoUrlColumn [

	^ photoUrlColumn
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> photoUrlColumn: aString [

	photoUrlColumn := aString
]

{ #category : 'operations' }
GolapNodeProductInfoRetriever >> productDataAt: aString forAll: aCollectionOfGolapNode interim: aBlock [

	| values |
	values := Dictionary new: aCollectionOfGolapNode size.
	aCollectionOfGolapNode do: [ :node | values at: node id put: (node at: aString ifAbsent: [ nil ]) ].
	^ values
]

{ #category : 'operations' }
GolapNodeProductInfoRetriever >> productDataFor: aGolapNode [

	^ aGolapNode data associations
]
