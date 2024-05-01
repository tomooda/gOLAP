Class {
	#name : 'GolapSnapshotListItemPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'snapshotName',
		'globalImage',
		'createdTimeLabel',
		'modifiedTimeLabel',
		'nameLabel'
	],
	#category : 'Golap-UI-Snapshot',
	#package : 'Golap-UI',
	#tag : 'Snapshot'
}

{ #category : 'layout' }
GolapSnapshotListItemPresenter class >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: #nameLabel expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: 'created: ' expand: false;
				   add: #createdTimeLabel)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: 'modified: ' expand: false;
				   add: #modifiedTimeLabel)
		  expand: false;
		  add: #globalImage expand: false;
		  yourself
]

{ #category : 'instance creation' }
GolapSnapshotListItemPresenter class >> on: aString [

	^ self new
		  snapshotName: aString;
		  yourself
]

{ #category : 'operations' }
GolapSnapshotListItemPresenter >> copySnapshot [

	(UIManager default request: '新しい名前を入力してください') ifNotNil: [ :newName | 
		(self snapshotDirectory / newName) exists ifTrue: [ 
			UIManager default alert: '既に使われています' ].
		self snapshotDirectory / snapshotName copyAllTo:
			self snapshotDirectory / newName ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> emptyImage [

	| form |
	form := Form extent: 64 @ 64.
	form getCanvas
		fillColor: Color white;
		line: 0 @ 0
		to: 64 @ 64
		width: 3
		color: Color black;
		line: 64 @ 0
		to: 0 @ 64
		width: 3
		color: Color black.
	^ form
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> getCreatedTime [

	^ snapshotName ifNil: [ '' ] ifNotNil: [ :name | 
		  | ref |
		  ref := self snapshotDirectory / name.
		  ref isDirectory
			  ifTrue: [ 
				  | timeRef |
				  timeRef := ref / 'createdTime'.
				  timeRef isFile
					  ifTrue: [ timeRef contents ]
					  ifFalse: [ 
						  | time |
						  time := ref creationTime.
						  time asDate printString , ' ' , time asTime print24 ] ]
			  ifFalse: [ '' ] ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> getGlobalImage [

	^ snapshotName ifNil: [ self emptyImage ] ifNotNil: [ :name | 
		  | ref |
		  ref := self snapshotDirectory / name / self globalImageFilename.
		  ref isFile
			  ifTrue: [ 
				  ref binaryReadStreamDo: [ :stream | 
					  (PNGReadWriter on: stream) nextImage scaledToSize: 128 @ 128 ] ]
			  ifFalse: [ self emptyImage ] ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> getModifiedTime [

	^ snapshotName ifNil: [ '' ] ifNotNil: [ :name | 
		  | ref |
		  ref := self snapshotDirectory / name.
		  ref isDirectory
			  ifTrue: [ 
				  | time |
				  time := (ref files collect: #modificationTime) max.
				  time asDate printString , ' ' , time asTime print24 ]
			  ifFalse: [ '' ] ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> getName [
	^ snapshotName ifNil: [ '-' ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> globalImageFilename [

	^ 'globalImage.png'
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> golapDirectory [
	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'initialization' }
GolapSnapshotListItemPresenter >> initializePresenters [

	super initializePresenters.
	nameLabel := self newLabel.
	globalImage := self newImage.
	createdTimeLabel := self newLabel.
	modifiedTimeLabel := self newLabel.
	self update
]

{ #category : 'operations' }
GolapSnapshotListItemPresenter >> launchSnapshot [

	| golap |
	golap := Golap new.
	golap open.
	golap restoreSnapshot: self snapshotDirectory / snapshotName
]

{ #category : 'operations' }
GolapSnapshotListItemPresenter >> openSnapshot [

	Golap allInstancesDo: [ :golap | 
		(golap basicSnapshotDirectory = (self snapshotDirectory / snapshotName) 
			 and: [ golap window isOpen ]) ifTrue: [ ^ golap window maximize ] ].
	^ self launchSnapshot
]

{ #category : 'operations' }
GolapSnapshotListItemPresenter >> removeSnapshot [

	(UIManager default confirm: snapshotName , 'を削除します') ifTrue: [ 
		(self snapshotDirectory / snapshotName)
			ensureDeleteAllChildren;
			ensureDelete ]
]

{ #category : 'operations' }
GolapSnapshotListItemPresenter >> renameSnapshot [

	(UIManager default request: '新しい名前を入力してください') ifNotNil: [ :newName | 
		(self snapshotDirectory / newName) exists ifTrue: [ 
			UIManager default alert: '既に使われています' ].
		self snapshotDirectory / snapshotName renameTo: newName ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> snapshotDirectory [

	^ (self golapDirectory / 'snapshots') ensureCreateDirectory
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> snapshotName [

	^ snapshotName
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> snapshotName: aString [

	snapshotName := aString.
	self snapshotNameChanged
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> snapshotNameChanged [

	nameLabel ifNotNil: [ nameLabel label: self getName ].
	globalImage ifNotNil: [ globalImage image: self getGlobalImage ].
	createdTimeLabel ifNotNil: [ 
		createdTimeLabel label: self getCreatedTime ].
	modifiedTimeLabel ifNotNil: [ 
		modifiedTimeLabel label: self getModifiedTime ]
]

{ #category : 'accessing' }
GolapSnapshotListItemPresenter >> update [

	nameLabel ifNotNil: [ nameLabel label: self getName ].
	globalImage ifNotNil: [ globalImage image: self getGlobalImage ]
]
