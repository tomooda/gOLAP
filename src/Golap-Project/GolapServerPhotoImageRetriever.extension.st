Extension { #name : 'GolapServerPhotoImageRetriever' }

{ #category : '*Golap-Project' }
GolapServerPhotoImageRetriever >> asJSON [

	| json |
	json := super asJSON.
	golapServerUrl ifNotNil: [
		json at: 'golapServerUrl' put: golapServerUrl asString ].
	imageServerUrl ifNotNil: [
		json at: 'imageServerUrl' put: imageServerUrl asString ].
	^ json
]
