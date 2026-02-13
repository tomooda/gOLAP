Trait {
	#name : 'TGolapSnapshotablePresenter',
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'instance creation' }
TGolapSnapshotablePresenter classSide >> fromJSON: aDictionary [

	^ self new fromJSON: aDictionary
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> asJSON [

	^ self subclassResponsibility
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> basicAsJSON [

	^ {
		  ('class' -> self class name asString).
		  ('window' -> self windowJSON).
		  ('bounds' -> self boundsJSON) } asOrderedDictionary
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> basicFromJSON: aDictionary [

	| bounds |
	aDictionary
		at: 'bounds' ifPresent: [ :array |
				bounds := array first @ array second corner:
						          array third @ array fourth ];
		at: 'window'
		ifPresent: [ :string | self fromWindowJSON: string bounds: bounds ]
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> boundsJSON [

	self window ifNotNil: [ :window |
			window withAdapterDo: [ :a |
					a widgetDo: [ :w |
							| bounds |
							bounds := w fullBounds.
							^ {
								  bounds origin x.
								  bounds origin y.
								  bounds corner x.
								  bounds corner y } ] ] ].
	^ nil
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

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> fromJSON: aDictionary [

	^ self subclassResponsibility
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> fromWindowJSON: aString bounds: aRectangle [

	[
		aString = 'open' ifTrue: [ ^ (self openBounds: aRectangle) open ].
		aString = 'minimized' ifTrue: [
				^ (self openBounds: aRectangle)
					  minimize;
					  open ].
		aString = 'maximized' ifTrue: [
				^ (self openBounds: aRectangle)
					  maximize;
					  open ].
		aRectangle ifNotNil: [
				^ self asWindow
					  initialPosition: aRectangle origin;
					  initialExtent: aRectangle extent ].
		^ nil ] ensure: [
			self currentWorld submorphs do: [ :morph |
					(morph model isKindOf: SpModalWindowPresenter) ifTrue: [
						morph comeToFront ] ] ]
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

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> windowJSON [

	self window ifNotNil: [ :window |
			window isMinimized ifTrue: [ ^ 'minimized' ].
			window isMaximized ifTrue: [ ^ 'maximized' ].
			window isOpen ifTrue: [ ^ 'open' ] ].
	^ 'closed'
]
