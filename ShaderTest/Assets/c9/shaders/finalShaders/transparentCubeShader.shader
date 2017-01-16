Shader "MyShader/c9/final/opaqueCubeShader"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white"{}
		_BumpMap("BumpMap", 2D) = "bump"{}
		_BumpScale("BumpScale", Range(-2, 2)) = 1
		_SpecularMap("SpecularMap", 2D) = "white"{}
		_SpecularScale("SpecularScale", Range(0, 1)) = 1
		_Shininess("Shininess", Range(8, 256)) = 128
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Opaque"
		}
//		Pass
//		{
//			Tags
//			{
//				"LightMode" = "ShadowCaster"
//			}
//			CGPROGRAM
//						
//			#pragma multi_compile_shadowcaster
//			#pragma vertex Vert
//			#pragma fragment Frag
//
//			#include "UnityCG.cginc"
//
//			struct v2f
//			{
//				V2F_SHADOW_CASTER;
//			};
//
//			v2f Vert(appdata_base v)
//			{
//				v2f o;
//				TRANSFER_SHADOW_CASTER(o);
//				return o;
//			}
//
//			fixed4 Frag(v2f i) : SV_Target
//			{
//				SHADOW_CASTER_FRAGMENT(i);
//			}
//
//			ENDCG
//		}
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			Blend SrcAlpha OneMinusSrcAlpha
			Cull Front
			ZWrite off

			CGPROGRAM

			#pragma multi_compile_fwdbase
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMap;
			fixed _SpecularScale;
			float _Shininess;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 t2w_0 : TEXCOORD0;
				float4 t2w_1 : TEXCOORD1;
				float4 t2w_2 : TEXCOORD2;
				float2 uv : TEXCOORD3;
			};

			v2f Vert(a2v v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv = v.texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;

				fixed3 worldPos = mul(_Object2World, v.vertex).xyz;
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.t2w_0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.t2w_1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.t2w_2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 Frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldHalf = normalize(worldLight + worldView);

				half3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				fixed3 worldNormal = normalize(half3(dot(i.t2w_0.xyz, bump),dot(i.t2w_1.xyz, bump),dot(i.t2w_2.xyz, bump)));

				fixed4 albedo = tex2D(_Albedo, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldLight, worldNormal));

				return fixed4(ambient + (diffuse), albedo.a);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			ZWrite off
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma multi_compile_fwdbase
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMap;
			fixed _SpecularScale;
			float _Shininess;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 t2w_0 : TEXCOORD0;
				float4 t2w_1 : TEXCOORD1;
				float4 t2w_2 : TEXCOORD2;
				float2 uv : TEXCOORD3;
			};

			v2f Vert(a2v v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv = v.texcoord.xy * _Albedo_ST.xy + _Albedo_ST.zw;

				fixed3 worldPos = mul(_Object2World, v.vertex).xyz;
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.t2w_0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.t2w_1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.t2w_2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 Frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldHalf = normalize(worldLight + worldView);

				half3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				fixed3 worldNormal = normalize(half3(dot(i.t2w_0.xyz, bump),dot(i.t2w_1.xyz, bump),dot(i.t2w_2.xyz, bump)));

				fixed4 albedo = tex2D(_Albedo, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldLight, worldNormal));

				return fixed4(ambient + (diffuse), albedo.a);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			Blend One One

			CGPROGRAM


			#pragma multi_compile_fwdadd
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMap;
			fixed _SpecularScale;
			float _Shininess;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 t2w_0 : TEXCOORD0;
				float4 t2w_1 : TEXCOORD1;
				float4 t2w_2 : TEXCOORD2;
				SHADOW_COORDS(3)
				float2 uv : TEXCOORD4;
			};

			v2f Vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				fixed3 worldPos = mul(_Object2World, v.vertex).xyz;

				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)_World2Object));
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 worldBitangent = cross(worldNormal, worldTangent) * v.tangent.w;

				o.t2w_0 = float4(worldTangent.x, worldBitangent.x, worldNormal.x, worldPos.x);
				o.t2w_1 = float4(worldTangent.y, worldBitangent.y, worldNormal.y, worldPos.y);
				o.t2w_2 = float4(worldTangent.z, worldBitangent.z, worldNormal.z, worldPos.z);

				o.uv = TRANSFORM_TEX(v.texcoord, _Albedo);

				return o;
			}

			fixed4 Frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.t2w_0.w,i.t2w_1.w,i.t2w_2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldHalf = normalize(worldLight + worldView);
				half3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

				fixed3 worldNormal = normalize(half3(dot(i.t2w_0.xyz, bump.xyz), dot(i.t2w_1.xyz, bump.xyz), dot(i.t2w_2.xyz, bump.xyz)));

				fixed4 albedo = tex2D(_Albedo, i.uv);

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0.rgb * pow(saturate(dot(worldHalf, worldNormal)), _Shininess) * tex2D(_SpecularMap, i.uv) * _SpecularScale;

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4((diffuse) * atten, 0);
			}

			ENDCG
		}
	}

	Fallback "Transparent/Cutout/VertexLit"
}