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

	^ (self confirm: '作業状態を保存しますか？' title: '作業状態の保存')
		  ifTrue: [
				  | json |
				  json := Dictionary new.
				  GolapNamedProject basicCurrent ifNotNil: [ :project |
					  json at: 'project' put: project projectName ].
				  json at: 'windows' put: super asJSON.
				  json ]
		  ifFalse: [ nil ]
]

{ #category : 'converting' }
GolapPhantasmicProject >> fromJSON: aDictionaryOrNil [

	aDictionaryOrNil ifNotNil: [
			(self confirm: '前回の作業状態を復元しますか？' title: '前回からの復元') ifTrue: [
					aDictionaryOrNil
						at: 'project'
						ifPresent: [ :projectName |
							GolapNamedProject current projectName: projectName ];
						at: 'windows' ifPresent: [ super fromJSON: aDictionaryOrNil ] ] ]
]
