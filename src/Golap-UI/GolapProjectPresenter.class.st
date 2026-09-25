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
	#classVars : [
		'Current'
	],
	#category : 'Golap-UI-Project',
	#package : 'Golap-UI',
	#tag : 'Project'
}

{ #category : 'sole instance' }
GolapProjectPresenter class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'menus' }
GolapProjectPresenter class >> golapMenuOn: aBuilder [

	<worldMenu>
	<golapMenu>
	(aBuilder item: #GolapOpenProjectPresenter)
		label: 'プロジェクト';
		iconName: #open;
		parent: #GolapFileMenu;
		order: 10;
		target: self;
		selector: #open;
		help: 'プロジェクトリストを開きます。'
]

{ #category : 'operations' }
GolapProjectPresenter class >> open [

	| window |
	window := self current window ifNil: [ self current asWindow ].
	window isOpen
		ifTrue: [ window activate ]
		ifFalse: [
				self current asWindow
					initialPosition:
						0 @ ((self currentWorld submorphs detect: [ :m | m top <= 1 ] ifNone: [ nil ]) ifNotNil: [ :m | m bottom ] ifNil: [ 0 ]);
					open ]
]

{ #category : 'operations' }
GolapProjectPresenter >> addProject [

	self requestNewProject ifNotNil: [ :project |
			self confirmToSaveCurrentProject ifNotNil: [
					project store.
					project beCurrent.
					self
						updateProjectList;
						selectProjectNamed: project projectName ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> alert: aString title: anotherString [

	(self application newAlert
		 message: aString;
		 title: anotherString;
		 asModalWindow)
		initialExtent: 500 @ 120;
		open
]

{ #category : 'ui requests' }
GolapProjectPresenter >> confirm: queryString title: titleString [

	^ self application newConfirm
		  title: titleString;
		  message: queryString;
		  openModal
]

{ #category : 'operations' }
GolapProjectPresenter >> confirmToSaveCurrentProject [

	^ self currentProject ifDefault: [ false ] otherwise: [ :current |
			  (self confirmYesNoCancel: current projectName , 'を保存しますか？' title: '保存の確認') ifNotNil: [ :save |
					  save
						  ifTrue: [ current store ifNil: [ self alert: current projectName , 'の保存に失敗しました。' title: '保存失敗' ] ];
						  yourself ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> confirmYesNoCancel: aString title: anotherString [

	^ (GolapConfirmYesNoCancelDialog newApplication: self application)
		  message: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProject [

	^ GolapProject current
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectFile [

	^ self currentProject projectFile
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectName [

	^ self currentProject projectName
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

{ #category : 'operations' }
GolapProjectPresenter >> removeProject [

	self selectedProjectFile ifNotNil: [ :ref |
			(self confirm: (self projectNameFor: ref) , 'を削除しますか？' title: 'プロジェクト削除') ifTrue: [
					ref ensureDelete.
					self currentProjectFile = ref ifTrue: [ GolapProject default beCurrent ].
					self updateProjectList ] ]
]

{ #category : 'operations' }
GolapProjectPresenter >> renameProject [

	self selectedProjectFile ifNotNil: [ :ref |
			self requestNewProject ifNotNil: [ :project |
					| name |
					name := self projectNameFor: ref.
					ref moveTo: project projectFile.
					name = self currentProjectName ifTrue: [ project beCurrent ].
					self
						updateProjectList;
						selectProjectNamed: project projectName ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> request: request initialAnswer: initialAnwser title: title [

	| answer |
	answer := self application newRequest
		          title: title;
		          message: request;
		          text: initialAnwser;
		          openModal.
	^ answer
]

{ #category : 'operations' }
GolapProjectPresenter >> requestNewProject [

	| projectName project |
	[
		[
			projectName := self request: '新規プロジェクト名' initialAnswer: '' title: '新規プロジェクト作成'.
			projectName ifNil: [ ^ nil ].
			projectName := projectName trim.
			[ FileSystem disk checkName: projectName fixErrors: false ]
				on: Error
				do: [ :ex |
						self alert: 'ファイル名に使える名前を入力してください。' title: 'プロジェクト名エラー'.
						projectName := nil ].
			projectName isNil ] whileTrue.
		project := GolapProject named: projectName.
		project exists ifTrue: [
				self alert: 'そのプロジェクト名は既に使われています。' title: 'プロジェクト名エラー'.
				project := nil ].
		project isNil ] whileTrue.
	^ project
]

{ #category : 'operations' }
GolapProjectPresenter >> saveProject [

	self currentProject store ifNil: [ self alert: self currentProjectName , 'の保存に失敗しました。' title: '保存失敗' ]
]

{ #category : 'selection' }
GolapProjectPresenter >> selectProjectNamed: aString [

	(projectList items detect: [ :ref | (self projectNameFor: ref) = aString ] ifNone: [ nil ])
		ifNotNil: [ :ref | projectList selectItem: ref ]
		ifNil: [ projectList unselectAll ]
]

{ #category : 'updating' }
GolapProjectPresenter >> selectedProjectChanged [

	self updateButtons
]

{ #category : 'selection' }
GolapProjectPresenter >> selectedProjectFile [

	^ projectList selectedItem
]

{ #category : 'selection' }
GolapProjectPresenter >> selectedProjectName [

	^ self selectedProjectFile ifNotNil: [ :ref | self projectNameFor: ref ]
]

{ #category : 'operations' }
GolapProjectPresenter >> switchProject [

	self selectedProjectFile ifNotNil: [ :ref |
			self confirmToSaveCurrentProject ifNotNil: [
					self currentProject closeAll.
					((GolapProject on: ref)
						 beCurrent;
						 load) ifNil: [ self alert: self currentProjectName , 'の読み込みに失敗しました。' title: '読み込み失敗' ].
					self updateProjectList ] ]
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
	self selectProjectNamed: selectedProjectName
]

{ #category : 'accessing' }
GolapProjectPresenter >> windowTitle [

	^ 'プロジェクト一覧'
]
