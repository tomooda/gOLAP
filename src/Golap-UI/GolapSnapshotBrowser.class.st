Class {
	#name : 'GolapSnapshotBrowser',
	#superclass : 'SpPresenter',
	#instVars : [
		'availableSnapshotList',
		'emptyImage',
		'snapshotView',
		'addSnapshotButton',
		'removeSnapshotButton',
		'openSnapshotButton',
		'renameSnapshotButton',
		'refreshSnapshotButton',
		'copySnapshotButton'
	],
	#category : 'Golap-UI-Snapshot',
	#package : 'Golap-UI',
	#tag : 'Snapshot'
}

{ #category : 'layout' }
GolapSnapshotBrowser class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #availableSnapshotList;
		  add: (SpBoxLayout newHorizontal
				   add: #refreshSnapshotButton width: 32;
				   add: #addSnapshotButton width: 32;
				   add: #copySnapshotButton width: 32;
				   add: #openSnapshotButton width: 32;
				   add: #renameSnapshotButton width: 32;
				   add: #removeSnapshotButton width: 32;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'utilities' }
GolapSnapshotBrowser class >> open [

	<script: 'GolapSnapshotBrowser open'>
	^ self new open
]

{ #category : 'operations' }
GolapSnapshotBrowser >> addSnapshot [

	self newMenu
		addItem: [ :item |
			item
				name: 'CSV';
				action: [ GolapCSVLauncher open ] ];
		addItem: [ :item |
			item
				name: 'Server';
				action: [ Golap openClient ] ];
		openWithSpecAtPointer
]

{ #category : 'accessing' }
GolapSnapshotBrowser >> allSnapshotNames [

	^ (self snapshotDirectory directoryNames reject: [ :name | 
		   name first = $. ]) asSortedCollection
]

{ #category : 'operations' }
GolapSnapshotBrowser >> copySnapshot [

	availableSnapshotList selectedItem ifNotNil: [ :item | 
		item copySnapshot.
		self updateAvailableSnapshotList ]
]

{ #category : 'accessing' }
GolapSnapshotBrowser >> golapDirectory [
	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'initialization' }
GolapSnapshotBrowser >> initializePresenters [

	super initializePresenters.
	availableSnapshotList := self newComponentList
		                         activateOnDoubleClick;
		                         whenActivatedDo: [ self openSnapshot ];
		                         whenSelectionChangedDo: [ 
			                         self updateButtons ];
		                         contextMenu: [ self snapshotListMenu ];
		                         yourself.
	refreshSnapshotButton := self newButton
		                         icon: Smalltalk ui icons smallUpdate;
		                         action: [ self updateAvailableSnapshotList ];
		                         enable;
		                         yourself.
	addSnapshotButton := self newButton
		                     icon: Smalltalk ui icons add;
		                     action: [ self addSnapshot ];
		                     enable;
		                     yourself.
	copySnapshotButton := self newButton
		                      icon: Smalltalk ui icons smallCopy;
		                      action: [ self copySnapshot ];
		                      disable;
		                      yourself.
	openSnapshotButton := self newButton
		                      icon: Smalltalk ui icons objects;
		                      action: [ self openSnapshot ];
		                      disable;
		                      yourself.
	renameSnapshotButton := self newButton
		                        icon: Smalltalk ui icons repair;
		                        action: [ self renameSnapshot ];
		                        disable;
		                        yourself.
	removeSnapshotButton := self newButton
		                        icon: Smalltalk ui icons remove;
		                        action: [ self removeSnapshot ];
		                        disable;
		                        yourself.
	self updateAvailableSnapshotList
]

{ #category : 'initialization' }
GolapSnapshotBrowser >> initializeWindow: aWindowPresenter [
	aWindowPresenter title: 'Snapshot Browser'
]

{ #category : 'operations' }
GolapSnapshotBrowser >> openSnapshot [

	availableSnapshotList selectedItem ifNotNil: [ :item | 
		item openSnapshot ]
]

{ #category : 'operations' }
GolapSnapshotBrowser >> removeSnapshot [

	availableSnapshotList selectedItem ifNotNil: [ :item | 
		item removeSnapshot.
		self updateAvailableSnapshotList ]
]

{ #category : 'operations' }
GolapSnapshotBrowser >> renameSnapshot [

	availableSnapshotList selectedItem ifNotNil: [ :item | 
		item renameSnapshot.
		self updateAvailableSnapshotList ]
]

{ #category : 'accessing' }
GolapSnapshotBrowser >> snapshotDirectory [

	^ (self golapDirectory / 'snapshots') ensureCreateDirectory
]

{ #category : 'menus' }
GolapSnapshotBrowser >> snapshotListMenu [

	^ self newMenu
		  addGroup: [ :group | 
			  group addItem: [ :item | 
					  item
						  name: 'Open';
						  action: [ self openSnapshot ] ] ];
		  addGroup: [ :group | 
			  group
				  addItem: [ :item | 
					  item
						  name: 'New...';
						  action: [ self addSnapshot ] ];
				  addItem: [ :item | 
					  item
						  name: 'Delete';
						  action: [ self removeSnapshot ] ];
				  addItem: [ :item | 
					  item
						  name: 'Copy';
						  action: [ self copySnapshot ] ];
				  addItem: [ :item | 
					  item
						  name: 'Rename';
						  action: [ self renameSnapshot ] ] ]
]

{ #category : 'updating' }
GolapSnapshotBrowser >> updateAvailableSnapshotList [

	availableSnapshotList items:
		(self allSnapshotNames collect: [ :name | 
			 GolapSnapshotListItemPresenter on: name ])
]

{ #category : 'updating' }
GolapSnapshotBrowser >> updateButtons [

	availableSnapshotList selectedItem
		ifNil: [ 
			removeSnapshotButton disable.
			copySnapshotButton disable.
			openSnapshotButton disable.
			renameSnapshotButton disable ]
		ifNotNil: [ 
			removeSnapshotButton enable.
			copySnapshotButton enable.
			openSnapshotButton enable.
			renameSnapshotButton enable ]
]
