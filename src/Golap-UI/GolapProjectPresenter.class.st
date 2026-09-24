Class {
	#name : 'GolapProjectPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'projectList',
		'addProjectButton',
		'renameProjectButton',
		'removeProjectButton',
		'saveProjectButton',
		'switchProjectButton'
	],
	#category : 'Golap-UI-Project',
	#package : 'Golap-UI',
	#tag : 'Project'
}

{ #category : 'operations-add' }
GolapProjectPresenter >> addProject [

	self selectedProjectFile ifNotNil: [ :ref | ref ~= self currentProjectFile ifTrue: [ ^ self duplicateProject: ref ] ].
	self saveAsProject
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectFile [

	^ GolapProject currentProjectFile
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectName [

	^ GolapProject currentProjectName
]

{ #category : 'layout' }
GolapProjectPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: projectList expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: addProjectButton expand: true;
				   add: renameProjectButton expand: true;
				   add: removeProjectButton expand: true;
				   yourself)
		  expand: false;
		  add: saveProjectButton expand: false;
		  add: switchProjectButton expand: false;
		  yourself
]

{ #category : 'operations-add' }
GolapProjectPresenter >> duplicateProject: aFileReference [

	^ self notYetImplemented
]

{ #category : 'accessing' }
GolapProjectPresenter >> iconFor: aFileReference [

	^ aFileReference = self currentProjectFile
		  ifTrue: [ self iconNamed: #accept ]
		  ifFalse: [ nil ]
]

{ #category : 'initialization' }
GolapProjectPresenter >> initializePresenters [

	super initializePresenters.
	projectList := self newTable
		               addColumn: ((SpImageTableColumn evaluated: [ :ref | self iconFor: ref ]) width: 32);
		               addColumn: (SpStringTableColumn title: 'プロジェクト名' evaluated: [ :ref | self projectNameFor: ref ]);
		               whenSelectedItemChangedDo: [ self selectedProjectChanged ];
		               yourself.
	projectList whenBuiltDo: [ :ann | ann widget allowDeselection ].
	addProjectButton := self newButton
		                    icon: (self iconNamed: #add);
		                    label: '作成';
		                    action: [ self addProject ];
		                    yourself.
	removeProjectButton := self newButton
		                       icon: (self iconNamed: #remove);
		                       label: '削除';
		                       action: [ self removeProject ];
		                       yourself.
	renameProjectButton := self newButton
		                       icon: (self iconNamed: #edit);
		                       label: '名前変更';
		                       action: [ self renameProject ];
		                       yourself.
	saveProjectButton := self newButton
		                     icon: (self iconNamed: #save);
		                     label: '保存';
		                     action: [ self saveProject ];
		                     yourself.
	switchProjectButton := self newButton
		                       icon: (self iconNamed: #accept);
		                       label: '開く';
		                       action: [ self switchProject ];
		                       yourself.
	self updateProjectList
]

{ #category : 'accessing' }
GolapProjectPresenter >> projectNameFor: aFileReference [

	^ aFileReference basenameWithoutExtension: GolapProject fileExtension
]

{ #category : 'operations-remove' }
GolapProjectPresenter >> removeProject [

	self selectedProjectFile ifNotNil: [ :ref |
			(self confirm: (self projectNameFor: ref) , 'を削除しますか？' label: 'プロジェクト削除') ifTrue: [
					ref ensureDelete.
					self currentProjectFile = ref ifTrue: [ GolapProject default beCurrent ].
					self updateProjectList ] ]
]

{ #category : 'operations-rename' }
GolapProjectPresenter >> renameProject [

	self selectedProjectFile ifNotNil: [ :ref | self renameProject: ref ]
]

{ #category : 'operations-rename' }
GolapProjectPresenter >> renameProject: aFileReference [

	^ self notYetImplemented
]

{ #category : 'operations-add' }
GolapProjectPresenter >> saveAsProject [

	^ self notYetImplemented
]

{ #category : 'operations-save' }
GolapProjectPresenter >> saveProject [

	^ self notYetImplemented
]

{ #category : 'updating' }
GolapProjectPresenter >> selectedProjectChanged [

	self updateButtons
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProjectFile [

	^ projectList selectedItem
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProjectName [

	^ self selectedProjectFile ifNotNil: [ :ref | self projectNameFor: ref ]
]

{ #category : 'operations-switch' }
GolapProjectPresenter >> switchProject [

	self selectedProjectFile ifNotNil: [ :ref | self switchProject: ref ]
]

{ #category : 'operations-switch' }
GolapProjectPresenter >> switchProject: aFileReference [

	^ self notYetImplemented
]

{ #category : 'updating' }
GolapProjectPresenter >> updateButtons [

	| selected current |
	selected := self selectedProjectName.
	current := self currentProjectName.
	removeProjectButton enabled: selected notNil.
	renameProjectButton enabled: selected notNil.
	saveProjectButton enabled: (selected notNil and: [ selected = current ]).
	switchProjectButton enabled: (selected notNil and: [ selected ~= current ])
]

{ #category : 'updating' }
GolapProjectPresenter >> updateProjectList [

	| selectedProjectName items |
	selectedProjectName := self selectedProjectName.
	items := GolapProject projectFiles.
	projectList items: items.
	(items includes: selectedProjectName) ifTrue: [ projectList selectItem: selectedProjectName ]
]

{ #category : 'accessing' }
GolapProjectPresenter >> windowTitle [

	^ 'プロジェクト一覧'
]
