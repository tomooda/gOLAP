Class {
	#name : 'BaselineOfGolap',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGolap',
	#package : 'BaselineOfGolap'
}

{ #category : 'baseline' }
BaselineOfGolap >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'ObjCBridge'
			with: [ spec repository: 'github://tesonep/objcbridge/src' ].
		spec
			baseline: 'Fleeter'
			with: [
			spec repository: 'github://tomooda/Phleeter:main/src' ].
		spec
			baseline: 'HiDeHo'
			with: [ spec repository: 'github://tomooda/HiDeHo:main/src' ].
		spec
			baseline: 'DataFrame'
			with: [ spec repository: 'github://PolyMathOrg/DataFrame/src' ].
		spec
			baseline: 'PetitParser2Core'
			with: [ spec repository: 'github://kursjan/petitparser2/' ].
		spec
			baseline: 'Xenq'
			with: [ spec repository: 'github://tomooda/Xenq:main/src' ].
		spec
			package: 'Golap-Application'
			with: [ spec requires: #( 'ObjCBridge' 'Phleeter' ) ].
		spec
			package: 'Golap-Networking'
			with: [ spec requires: #( 'DataFrame' ) ].
		spec
			package: 'Golap-Query'
			with: [ spec requires: #( 'PetitParser2Core' ) ].
		spec package: 'Golap-UI' with: [
			spec requires:
				#( 'Golap-Clustering' 'Golap-Models' 'Golap-Networking'
				   'Golap-Query' 'HiDeHo' 'DataFrame' 'Xenq' ) ].
		spec
			package: 'Golap-Models'
			with: [ spec requires: #( 'DataFrame' 'Golap-Clustering' ) ].
		spec package: 'Golap-Clustering' with: [ spec requires: #(  ) ].
		spec postLoadDoIt: #postLoad.
		spec
			group: 'Core'
			with:
				#( 'Golap-Models' 'Golap-UI' 'Golap-Query' 'Golap-Networking'
				   'Golap-Clustering' 'Golap-Application' );
			group: 'default' with: #( 'Core' ) ]
]

{ #category : 'utilities' }
BaselineOfGolap >> installDesktopLogo [

	<script: 'BaselineOfGolap new installDesktopLogo'>
	| backgroundImage |
	backgroundImage := (FileLocator localDirectory / 'gOLAP')
		                   ensureCreateDirectory / 'gOLAP-logo.png'.
	PharoLightTheme beCurrent.
	backgroundImage ensureDelete.
	(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
	/ backgroundImage basename copyTo: backgroundImage.
	PolymorphSystemSettings desktopLogoFileName: ''.
	PolymorphSystemSettings desktopLogoFileName: backgroundImage fullName
]

{ #category : 'utilities' }
BaselineOfGolap >> installFonts [

	<script: 'BaselineOfGolap new installFonts'>
	(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
	/ 'Fonts' copyAllTo:
		(FileLocator workingDirectory / 'Fonts') ensureCreateDirectory.
	Smalltalk at: #PlemolJPRegular ifPresent: [ :fontClass |
		EmbeddedFreeTypeFontInstaller registerFont: fontClass.
		FreeTypeFontProvider current buildFamilies.
		StandardFonts setAllStandardFontsTo:
			(LogicalFont familyName: 'PlemolJP' pointSize: 10) ]
]

{ #category : 'utilities' }
BaselineOfGolap >> postLoad [

	self
		installDesktopLogo;
		installFonts
]
