// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ink_Fresnel_ASE_NoUV"
{
	Properties
	{
		_Outline_Width1("Outline_Width", Range( 0 , 0.7)) = 0.1
		_Outline_Smoothness1("Outline_Smoothness", Range( 0 , 0.1)) = 0.05
		_NoiseTex1("NoiseTex", 2D) = "gray" {}
		_Outline_NoiseStrength1("Outline_NoiseStrength", Range( 0 , 1)) = 0.1
		_MC_Tint1("MC_Tint1", Color) = (1,1,1,1)
		_MC_Tint2("MC_Tint2", Color) = (0.2264151,0.2264151,0.2264151,1)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _MC_Tint1;
		uniform float4 _MC_Tint2;
		uniform sampler2D _NoiseTex1;
		uniform float4 _NoiseTex1_ST;
		uniform float _Outline_Width1;
		uniform float _Outline_Smoothness1;
		uniform float _Outline_NoiseStrength1;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 temp_cast_1 = (0.0).xxx;
			c.rgb = temp_cast_1;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult27 = (float2(ase_worldPos.x , ase_worldPos.y));
			float4 NoiseColor37 = tex2D( _NoiseTex1, ( _NoiseTex1_ST.zw + ( _NoiseTex1_ST.xy * appendResult27 ) ) );
			float4 lerpResult46 = lerp( _MC_Tint1 , _MC_Tint2 , NoiseColor37.g);
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 objToWorldDir36 = mul( unity_ObjectToWorld, float4( ase_vertexNormal, 0 ) ).xyz;
			float dotResult28 = dot( objToWorldDir36 , i.viewDir );
			float smoothstepResult24 = smoothstep( _Outline_Width1 , ( _Outline_Width1 + _Outline_Smoothness1 ) , ( ( ( ( NoiseColor37.r + -0.5 ) * 2.0 ) * _Outline_NoiseStrength1 ) + abs( dotResult28 ) ));
			o.Emission = ( lerpResult46 * smoothstepResult24 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
332.8;654.4;1210.4;746.2;1081.062;851.1716;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;40;-1516.123,-1221.101;Inherit;False;1414.553;462.5927;采样噪点贴图;8;25;30;32;27;33;34;8;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-1450.819,-939.1088;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;25;-1466.123,-1171.101;Inherit;True;Property;_NoiseTex1;NoiseTex;2;0;Create;True;0;0;0;False;0;False;83e7d892f31526a40bdd44154aabc53d;d2c83be376b4bef4a94709c1112f64ab;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;27;-1243.253,-912.9469;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;32;-1146.829,-1060.348;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-954.8306,-965.3479;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-825.8306,-994.3479;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;8;-692.7156,-1154.101;Inherit;True;Property;_TextureSample1;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-326.3706,-1161.817;Inherit;False;NoiseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;10;-1292.602,-20.80339;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1545.785,-426.3091;Inherit;False;37;NoiseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;11;-1283.557,175.3925;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;36;-1077.198,-23.30612;Inherit;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;39;-1342.785,-416.3091;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;13;-1139.446,-422.9792;Inherit;False;ConstantBiasScale;-1;;2;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-834.088,82.63132;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1274.986,-221.1558;Inherit;False;Property;_Outline_NoiseStrength1;Outline_NoiseStrength;3;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-837.6263,352.127;Inherit;False;Property;_Outline_Smoothness1;Outline_Smoothness;1;0;Create;True;0;0;0;False;0;False;0.05;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-928.4457,-347.9792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;29;-673.2176,105.4858;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-842.8604,243.6745;Inherit;False;Property;_Outline_Width1;Outline_Width;0;0;Create;True;0;0;0;False;0;False;0.1;0;0;0.7;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-550.9177,-142.5409;Inherit;False;37;NoiseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-542.806,77.96413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-478.6261,276.127;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-540.9177,-415.5409;Inherit;False;Property;_MC_Tint2;MC_Tint2;5;0;Create;True;0;0;0;False;0;False;0.2264151,0.2264151,0.2264151,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;42;-300.9177,-136.5409;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;43;-543.9177,-587.5409;Inherit;False;Property;_MC_Tint1;MC_Tint1;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;24;-291.02,96.48134;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;46;-39.91772,-349.5409;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-208.2101,313.7346;Inherit;False;Constant;_Float1;Float 0;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;154.0823,-93.54089;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;366,-116;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Ink_Fresnel_ASE_NoUV;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;30;1
WireConnection;27;1;30;2
WireConnection;32;0;25;0
WireConnection;33;0;32;0
WireConnection;33;1;27;0
WireConnection;34;0;32;1
WireConnection;34;1;33;0
WireConnection;8;0;25;0
WireConnection;8;1;34;0
WireConnection;8;7;25;1
WireConnection;37;0;8;0
WireConnection;36;0;10;0
WireConnection;39;0;38;0
WireConnection;13;3;39;0
WireConnection;28;0;36;0
WireConnection;28;1;11;0
WireConnection;16;0;13;0
WireConnection;16;1;14;0
WireConnection;29;0;28;0
WireConnection;19;0;16;0
WireConnection;19;1;29;0
WireConnection;22;0;18;0
WireConnection;22;1;20;0
WireConnection;42;0;41;0
WireConnection;24;0;19;0
WireConnection;24;1;18;0
WireConnection;24;2;22;0
WireConnection;46;0;43;0
WireConnection;46;1;45;0
WireConnection;46;2;42;1
WireConnection;48;0;46;0
WireConnection;48;1;24;0
WireConnection;0;2;48;0
WireConnection;0;13;23;0
ASEEND*/
//CHKSM=4F7B0AF87767315B42BECB533FD80185495E8FD3