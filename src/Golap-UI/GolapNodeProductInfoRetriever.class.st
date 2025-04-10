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

	^ 'csv'
]

{ #category : 'converting' }
GolapNodeProductInfoRetriever >> asJSON [

	^ { ('photo-url-column' -> photoUrlColumn) } asOrderedDictionary
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> availableColumns [

	^ availableColumns
]

{ #category : 'accessing' }
GolapNodeProductInfoRetriever >> availableColumns: anArrayOfString [

	availableColumns := anArrayOfString
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

{ #category : 'private' }
GolapNodeProductInfoRetriever >> setFromJSON: aDictionary [

	aDictionary
		at: 'photo-url-column'
		ifPresent: [ :string | photoUrlColumn := string ]
]
