Extension { #name : 'GolapNodeProductInfoRetriever' }

{ #category : '*Golap-Project' }
GolapNodeProductInfoRetriever >> asJSON [

	| json |
	json := super asJSON.
	availableColumns ifNotNil: [
		json at: 'avaiableColumns' put: availableColumns ].
	photoUrlColumn ifNotNil: [
		json at: 'photoUrlColumn' put: photoUrlColumn ].
	^ json
]

{ #category : '*Golap-Project' }
GolapNodeProductInfoRetriever >> fromJSON: aDictionary [

	aDictionary
		at: 'avaiableColumns'
		ifPresent: [ :array | availableColumns := array ];
		at: 'photoUrlColumn'
		ifPresent: [ :string | photoUrlColumn := string ].
	super fromJSON: aDictionary
]
