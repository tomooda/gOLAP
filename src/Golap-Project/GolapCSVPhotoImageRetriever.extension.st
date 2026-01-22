Extension { #name : 'GolapCSVPhotoImageRetriever' }

{ #category : '*Golap-Project' }
GolapCSVPhotoImageRetriever >> asJSON [

	| json |
	json := super asJSON.
	csvRef ifNotNil: [ json at: 'csvRef' put: csvRef fullName ].
	dataframe ifNotNil: [
			json at: 'dataframe' put: (dataframe ifNotNil: [
						 {
							 ('columnNames' -> dataframe columnNames).
							 ('data' -> dataframe asArray) } asDictionary ]) ].
	idColumn ifNotNil: [ json at: 'idColumn' put: idColumn ].
	photoColumn ifNotNil: [ json at: 'photoColumn' put: photoColumn ].
	urlPrefix ifNotNil: [ json at: 'urlPrefix' put: urlPrefix ].
	urlPostfix ifNotNil: [ json at: 'urlPostfix' put: urlPostfix ].
	^ json
]

{ #category : '*Golap-Project' }
GolapCSVPhotoImageRetriever >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'csvRef'
		ifPresent: [ :string | csvRef := string ifNotNil: #asFileReference ];
		at: 'dataframe' ifPresent: [ :dict |
				dataframe := DataFrame
					             withRows: (dict at: 'data' ifAbsent: [ Array new ])
					             columnNames:
						             (dict at: 'columnNames' ifAbsent: [ Array new ]) ];
		at: 'idColumn' ifPresent: [ :string | idColumn := string ];
		at: 'photoColumn' ifPresent: [ :string | photoColumn := string ];
		at: 'urlPostfix' ifPresent: [ :string | urlPostfix := string ];
		at: 'urlPrefix' ifPresent: [ :string | urlPrefix := string ]
]
