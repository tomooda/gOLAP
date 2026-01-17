Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#category : 'Golap-UI-Snapshot',
	#package : 'Golap-UI',
	#tag : 'Snapshot'
}

{ #category : 'converting' }
GolapProject >> asJSON [

	^ Array streamContents: [ :stream |
			  self currentWorld taskbars do: [ :taskbar |
					  taskbar submorphs do: [ :m1 |
							  m1 model ifNotNil: [ :m2 |
									  m2 model ifNotNil: [ :m3 |
											  m3 presenter ifNotNil: [ :p |
												  (p respondsTo: #asJSON) ifTrue: [
													  stream nextPut: p asJSON ] ] ] ] ] ] ]
]

{ #category : 'converting' }
GolapProject >> fromJSON: anArray [

	anArray do: [ :json |
			json at: 'class' ifPresent: [ :className |
					(TGolapSnapshotablePresenter users
						 detect: [ :class | class name asString = className ]
						 ifNone: [ nil ]) ifNotNil: [ :class | class fromJSON: json ] ] ]
]
