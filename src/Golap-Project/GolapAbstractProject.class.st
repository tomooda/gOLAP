Class {
	#name : 'GolapAbstractProject',
	#superclass : 'Object',
	#classInstVars : [
		'current'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'sole instance' }
GolapAbstractProject class >> basicCurrent [

	^ current
]

{ #category : 'sole instance' }
GolapAbstractProject class >> current [

	^ current ifNil: [ current := self new ]
]

{ #category : 'accessing' }
GolapAbstractProject class >> fileExtension [

	^ 'golap'
]

{ #category : 'sole instance' }
GolapAbstractProject class >> flushCurrent [

	current := nil
]

{ #category : 'accessing' }
GolapAbstractProject class >> golapDirectory [

	^ Golap golapDirectory
]

{ #category : 'ui requests' }
GolapAbstractProject >> application [

	^ SpApplication defaultApplication
]

{ #category : 'converting' }
GolapAbstractProject >> asJSON [

	^ Array streamContents: [ :stream |
			  self golapWindows do: [ :window |
				  stream nextPut: window presenter asJSON ] ]
]

{ #category : 'ui requests' }
GolapAbstractProject >> confirm: aString title: anotherString [

	^ self application newConfirm
		  label: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'ui requests' }
GolapAbstractProject >> confirmYesNoCancel: aString title: anotherString [

	^ (GolapConfirmYesNoCancelDialog newApplication: self application)
		  label: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'converting' }
GolapAbstractProject >> fromJSON: anArray [

	| dialog |
	dialog := SpProgressDialog new.
	dialog
		title: '復元中...';
		informUserDuring: [ :progress |
				| widget |
				widget := dialog adapter widget.
				anArray withIndexDo: [ :json :index |
							progress progressPercent: index * 100 // anArray size.
							json at: 'class' ifPresent: [ :className |
										(TGolapSnapshotablePresenter users
											 detect: [ :class | class name asString = className ]
											 ifNone: [ nil ]) ifNotNil: [ :class |
												class fromJSON: json ] ] ] ]
]

{ #category : 'accessing' }
GolapAbstractProject >> golapWindows [

	^ Array streamContents: [ :stream |
		  self golapWindowsDo: [ :window | stream nextPut: window ] ]
]

{ #category : 'enumerating' }
GolapAbstractProject >> golapWindowsDo: aBlock [

	| presenterClasses |
	presenterClasses := TGolapSnapshotablePresenter users.
	self currentWorld taskbars do: [ :taskbar |
			taskbar submorphs do: [ :morph |
					([ morph model model presenter ]
						 on: MessageNotUnderstood
						 do: [ :ex | ex return: nil ]) ifNotNil: [ :p |
						(presenterClasses includes: p class) ifTrue: [
							aBlock value: p window ] ] ] ]
]
