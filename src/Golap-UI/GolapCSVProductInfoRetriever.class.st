Class {
	#name : 'GolapCSVProductInfoRetriever',
	#superclass : 'GolapProductInfoRetriever',
	#instVars : [
		'photoUrlColumn'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapCSVProductInfoRetriever class >> photoUrlColumn: aString [

	^ self new
		  photoUrlColumn: aString;
		  yourself
]

{ #category : 'accessing' }
GolapCSVProductInfoRetriever class >> tag [

	^ 'csv'
]

{ #category : 'converting' }
GolapCSVProductInfoRetriever >> asJSON [

	^ {
		  'photo-url-column'.
		  photoUrlColumn } asOrderedDictionary
]

{ #category : 'testing' }
GolapCSVProductInfoRetriever >> hasPhotoImage [

	^ photoUrlColumn notNil
]

{ #category : 'accessing' }
GolapCSVProductInfoRetriever >> photoUrlColumn [

	^ photoUrlColumn
]

{ #category : 'accessing' }
GolapCSVProductInfoRetriever >> photoUrlColumn: aString [

	photoUrlColumn := aString
]

{ #category : 'accessing' }
GolapCSVProductInfoRetriever >> photoimageFor: aGolapNode [

	aGolapNode data at: photoUrlColumn ifPresent: [ :string |
		string ifNotNil: [
			[
			^ ImageReadWriter formFromStream:
				  string asUrl retrieveBinaryContents readStream ]
				on: Error
				do: [ :ex | nil ] ] ].
	^ nil
]

{ #category : 'accessing' }
GolapCSVProductInfoRetriever >> productDataFor: aGolapNode [

	^ aGolapNode data associations
]

{ #category : 'private' }
GolapCSVProductInfoRetriever >> setFromJSON: aDictionary [

	aDictionary
		at: 'photo-url-column'
		ifPresent: [ :string | photoUrlColumn := string ]
]
