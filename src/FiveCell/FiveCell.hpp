#ifndef FIVE_CELL_HPP
#define FIVE_CELL_HPP

//#define NUM_RAYS 5 
//#define MAX_MANDEL_STEPS 512 
#define NUM_FFT_BINS 512

#include <string>
#include <vector>

#ifdef __APPLE__
#include "rapidmix.h"
#elif _WIN32
#include "RapidLib/regression.h"
#endif

#include "SoundObject.hpp"
#include "CsoundSession.hpp"

class FiveCell {

public:
	
	//struct to hold data for raymarch shader
	struct RaymarchData{
		float tanFovYOver2;
		float aspect;
	};

	//bools to control machine learning
	struct MachineLearning{
		bool bRecord;
		bool bRandomParams;
		bool bTrainModel;
		bool bRunModel;
		bool bSaveTrainingData;
		bool bHaltModel;
		bool bLoadTrainingData;
		bool bSaveModel;
		bool bLoadModel;
	};

	bool setup(std::string csd);
	bool BSetupRaymarchQuad(GLuint shaderProg);
	void update(glm::mat4 viewMat, glm::vec3 camPos, MachineLearning& machineLearning, glm::vec3 controllerWorldPos);
	void draw(glm::mat4 projMat, glm::mat4 viewMat, glm::mat4 eyeMat, RaymarchData& raymarchData, GLuint mengerProg);
	void exit();

private:

	glm::vec4 cameraPos;
	glm::vec3 camPosPerEye;
	float deltaTime;
	float lastFrame;
	float currentFrame;

	//matrices 
	glm::mat4 modelMatrix;
	glm::mat4 scale5CellMatrix;
	glm::mat4 fiveCellModelMatrix;
	glm::mat4 groundModelMatrix;
	glm::mat4 skyboxModelMatrix;

	//lights
	glm::vec3 lightPos;
	glm::vec3 light2Pos;

	//Csound
	CsoundSession *session;
	MYFLT* hrtfVals[3];
	MYFLT* randWgbowFreqVal;
	MYFLT* randWgbowAmpVal;
	MYFLT* randWgbowPressureVal;
	MYFLT* randWgbowPositionVal;
	MYFLT* m_pRmsOut;
	MYFLT* m_pFftAmpBinOut[NUM_FFT_BINS];
	MYFLT* m_cspSineControlVal;
	//MYFLT* m_cspMandelEscapeVals[MAX_MANDEL_STEPS];
	//MYFLT* m_cspMandelEscapeIndex;
	//MYFLT* m_cspMaxSteps;

	//raymarching quad
	unsigned int m_uiNumSceneVerts;
	unsigned int m_uiNumSceneIndices;
	unsigned int m_uiNumSceneTexCoords;

	GLuint m_uiglSceneVAO;
	GLuint m_uiglSceneVBO;
	GLuint m_uiglIndexBuffer;
	GLuint m_uiglSkyboxTexLoc;
	GLuint m_uiglGroundTexLoc;

	GLuint m_uiglCubeMoonDirectionLoc;
	GLuint m_uiglCubeMoonColourLoc;
	GLuint m_uiglCubeMoonAmbientLoc;
	GLuint m_uiglCubeMoonDiffuseLoc;
	GLuint m_uiglCubeMoonSpecularLoc;

	GLuint m_uiglCubeMaterialAmbientLoc;
	GLuint m_uiglCubeMaterialDiffuseLoc;
	GLuint m_uiglCubeMaterialSpecularLoc;
	GLuint m_uiglCubeMaterialShininessLoc;

	GLuint m_uiglGroundPlaneColourLoc;
	GLuint m_uiglGroundPlaneAmbientLoc;
	GLuint m_uiglGroundPlaneDiffuseLoc;
	GLuint m_uiglGroundPlaneSpecularLoc;
	GLuint m_uiglGroundPlaneShininessLoc;

	GLint m_gliMVEPMatrixLocation;
	GLint m_gliInverseMVEPLocation;
	GLint m_gliRandomSizeLocation;
	GLint m_gliRMSModulateValLocation;
	GLint m_gliSineControlValLoc;
	GLuint m_gluiFftAmpBinsLoc;
	GLint m_gliNumFftBinsLoc;

	float sizeVal;
	float modulateVal;

	glm::mat4 raymarchQuadModelMatrix;
	glm::mat4 modelViewEyeMat;
	glm::mat4 inverseMVEMat;
	glm::mat4 modelViewEyeProjectionMat;
	glm::mat4 inverseMVEPMat;
	
	//machine learning
#ifdef __APPLE__
	rapidmix::staticRegression staticRegression;
	rapidmix::trainingData trainingData;
#elif _WIN32
	regression staticRegression;
	trainingExample trainingData;
	std::vector<trainingExample> trainingSet;
	bool m_bPrevRunHaltState;
#endif

	std::vector<double> inputData;
	std::vector<double> outputData;	

	bool m_bPrevSaveState;
	bool m_bPrevRandomState;
	bool m_bPrevTrainState;
	bool m_bPrevHaltState;
	bool m_bPrevLoadState;
	bool m_bCurrentMsgState;
	bool m_bMsg;
	bool m_bRunMsg;
	bool m_bCurrentRunMsgState;

	//lighting components
	glm::vec3 m_vec3MoonDirection;
	glm::vec3 m_vec3MoonColour;
	glm::vec3 m_vec3MoonAmbient;
	glm::vec3 m_vec3MoonDiffuse;
	glm::vec3 m_vec3MoonSpecular;
	
	//material properties
	glm::vec3 m_vec3GroundColour;
	glm::vec3 m_vec3GroundAmbient;
	glm::vec3 m_vec3GroundDiffuse;
	glm::vec3 m_vec3GroundSpecular;
	float m_fGroundShininess;

	glm::vec3 m_vec3CubeAmbient;
	glm::vec3 m_vec3CubeDiffuse;
	glm::vec3 m_vec3CubeSpecular;
	float m_fCubeShininess;

	//control variables
	float sineControlVal;

	float m_iMaxSteps;

	// variables for fft analysis
	std::string fftAmpBinsOut[NUM_FFT_BINS];	
	
	float m_fPrevRms;
};
#endif
