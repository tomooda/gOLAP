Trait {
	#name : 'TGolapSnapshotablePresenter',
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
TGolapSnapshotablePresenter classSide >> fromJSON: aDictionary [

	^ self new fromJSON: aDictionary
]

{ #category : 'projects' }
TGolapSnapshotablePresenter >> asJSON [

	^ self subclassResponsibility
]

{ #category : 'projects' }
TGolapSnapshotablePresenter >> basicAsJSON [

	^ { ('class' -> self class name asString) } asOrderedDictionary
]

{ #category : 'projects' }
TGolapSnapshotablePresenter >> basicFromJSON: aDictionary [

	aDictionary at: 'window' ifPresent: [ :string | GolapProjectPresenter current addPresenter: self ]
]

{ #category : 'ui requests' }
TGolapSnapshotablePresenter >> confirm: queryString title: titleString [

	^ self application newConfirm
		  title: titleString;
		  message: queryString;
		  openModal
]

{ #category : 'projects' }
TGolapSnapshotablePresenter >> fromJSON: aDictionary [

	^ self subclassResponsibility
]

{ #category : 'operations' }
TGolapSnapshotablePresenter >> open [

	self openInNotebook
]

{ #category : 'operations' }
TGolapSnapshotablePresenter >> openInNotebook [

	GolapProjectPresenter current addPresenter: self
]

{ #category : 'updating' }
TGolapSnapshotablePresenter >> selectedPageChanged [

	^ self subclassResponsibility
]
