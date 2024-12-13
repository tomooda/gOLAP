Class {
	#name : 'GolapNodeProductInfoRetriever',
	#superclass : 'GolapProductInfoRetriever',
	#instVars : [
		'photoUrlColumn',
		'availableColumns'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
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

{ #category : 'defaults' }
GolapNodeProductInfoRetriever >> defaultPhotoimageRetrievers [

	^ { (GolapAttributePhotoImageRetriever new
		   availableColumns: availableColumns;
		   photoColumn: photoUrlColumn;
		   yourself) }
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