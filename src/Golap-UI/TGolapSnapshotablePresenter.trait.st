Trait {
	#name : 'TGolapSnapshotablePresenter',
	#category : 'Golap-UI',
	#package : 'Golap-UI'
}

{ #category : 'instance creation' }
TGolapSnapshotablePresenter classSide >> fromJSON: aDictionary [

	^ self new fromJSON: aDictionary
]

{ #category : 'initialization' }
TGolapSnapshotablePresenter >> close [

	self window ifNotNil: #close
]

{ #category : 'ui requests' }
TGolapSnapshotablePresenter >> confirm: queryString label: titleString [

	^ self application newConfirm
		  title: titleString;
		  label: queryString;
		  openModal
]

{ #category : 'ui requests' }
TGolapSnapshotablePresenter >> confirmClose [

	^ self isForceClosing or: [
		  self confirm: self window title , 'を閉じますか？' label: '確認' ]
]

{ #category : 'initialization' }
TGolapSnapshotablePresenter >> forceClose [

	self close
]

{ #category : 'ui requests' }
TGolapSnapshotablePresenter >> isForceClosing [

	| context |
	context := thisContext sender.
	[ context notNil ] whileTrue: [
			(context receiver == self and: [ context selector = #forceClose ])
				ifTrue: [ ^ true ].
			context := context sender ].
	^ false
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> openBounds: aRectangle [

	| window |
	window := self asWindow.
	aRectangle ifNotNil: [
			window
				initialPosition: aRectangle origin;
				initialExtent: aRectangle extent ].
	^ window
]
