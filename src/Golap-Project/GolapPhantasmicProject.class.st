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
	json := Dictionary new.
	GolapNamedProject basicCurrent ifNotNil: [ :project |
		json at: 'project' put: project projectName ].
	json at: 'windows' put: super asJSON.
	^ json
]

{ #category : 'converting' }
GolapPhantasmicProject >> fromJSON: aDictionaryOrNil [

	aDictionaryOrNil ifNotNil: [
			aDictionaryOrNil
				at: 'project'
				ifPresent: [ :projectName |
					GolapNamedProject current projectName: projectName ];
				at: 'windows' ifPresent: [ :windows | super fromJSON: windows ] ]
]
