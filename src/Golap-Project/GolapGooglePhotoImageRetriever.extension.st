Extension { #name : 'GolapGooglePhotoImageRetriever' }

{ #category : '*Golap-Project' }
GolapGooglePhotoImageRetriever >> asJSON [

	| json |
	json := super asJSON.
	numImages ifNotNil: [ json at: 'numImages' put: numImages ].
	enabled ifNotNil: [ json at: 'enabled' put: enabled ].
	^ json
]
