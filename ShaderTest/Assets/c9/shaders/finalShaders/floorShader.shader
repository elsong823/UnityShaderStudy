Shader "MyShader/c9/final/floorShader"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white"{}
		_BumpMap("BumpMap", 2D) = "bump"{}
		_BumpScale("BumpScale", Range(-2, 2)) = 1
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess("Shininess", Range(8, 256)) = 128
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
			//很重要，否则没有阴影（阴影衰减）
			#pragma multi_compile_fwdbase
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _BumpMap;
			fixed4 _Specular;
			fixed _BumpScale;
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
				SHADOW_COORDS(4)
			};

			v2f Vert(in a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord, _Albedo);

				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				float3 worldPos = mul(_Object2World, v.vertex).xyz;

				o.t2w_0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.t2w_1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.t2w_2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				float3 worldPos = float3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldHalf = normalize(worldLight + worldView);
				//计算法线
				//读取法线贴图
				half3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				//计算法线
				fixed3 worldNormal = normalize(half3(dot(i.t2w_0.xyz, bump), dot(i.t2w_1.xyz, bump), dot(i.t2w_2.xyz, bump)));

				fixed4 albedo = tex2D(_Albedo, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldHalf, worldNormal)), _Shininess);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}
			Blend SrcAlpha One
			
			CGPROGRAM


			//很重要，否则没有阴影（阴影衰减）
			#pragma multi_compile_fwdadd
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _BumpMap;
			fixed4 _Specular;
			fixed _BumpScale;
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
				SHADOW_COORDS(4)
			};

			v2f Vert(in a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord, _Albedo);

				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				float3 worldPos = mul(_Object2World, v.vertex).xyz;

				o.t2w_0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.t2w_1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.t2w_2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				float3 worldPos = float3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldHalf = normalize(worldLight + worldView);
				//计算法线
				//读取法线贴图
				half3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				//计算法线
				fixed3 worldNormal = normalize(half3(dot(i.t2w_0.xyz, bump), dot(i.t2w_1.xyz, bump), dot(i.t2w_2.xyz, bump)));

				fixed4 albedo = tex2D(_Albedo, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldHalf, worldNormal)), _Shininess);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4((diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}


	}

	Fallback "VertexLit"	
}