Class {
	#name : 'GolapPhantasmicProject',
	#superclass : 'GolapAbstractProject',
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'converting' }
GolapPhantasmicProject class >> asJSON [

	^ self current asJSON
]

{ #category : 'converting' }
GolapPhantasmicProject class >> fromJSON: aDictionaryOrNil [

	self current fromJSON: aDictionaryOrNil
]

{ #category : 'converting' }
GolapPhantasmicProject >> asJSON [

	| json |
	json := super asJSON.
	GolapNamedProject basicCurrent ifNotNil: [ :project |
		json at: 'project' put: project projectName ].
	^ json
]

{ #category : 'converting' }
GolapPhantasmicProject >> fromJSON: aDictionaryOrNil [

	aDictionaryOrNil ifNotNil: [
			aDictionaryOrNil at: 'project' ifPresent: [ :projectName |
					projectName ifNotNil: [
						GolapNamedProject current projectName: projectName ] ].
			super fromJSON: aDictionaryOrNil ]
]
