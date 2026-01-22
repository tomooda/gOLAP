Extension { #name : 'GolapAttributePhotoImageRetriever' }

{ #category : '*Golap-Project' }
GolapAttributePhotoImageRetriever >> asJSON [

	| json |
	json := super asJSON.
	photoColumn ifNotNil: [ json at: 'photoColumn' put: photoColumn ].
	availableColumns ifNotNil: [
		json at: 'availableColumns' put: availableColumns ].
	^ json
]

{ #category : '*Golap-Project' }
GolapAttributePhotoImageRetriever >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'photoColumn' ifPresent: [ :string | photoColumn := string ];
		at: 'availableColumns'
		ifPresent: [ :array | availableColumns := array ]
]
