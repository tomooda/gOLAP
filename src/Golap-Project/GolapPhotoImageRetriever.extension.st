Extension { #name : 'GolapPhotoImageRetriever' }

{ #category : '*Golap-Project' }
GolapPhotoImageRetriever >> asJSON [

	^ {
		  ('tag' -> self class tag).
		  ('enabled' -> self enabled) } asDictionary
]

{ #category : '*Golap-Project' }
GolapPhotoImageRetriever >> fromJSON: aDictionary [

	
]
