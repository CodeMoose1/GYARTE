using Godot;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class DataAccess : Node
{
	Dictionary<Vector3I, float[]> chunkData = new Dictionary<Vector3I, float[]>();
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public void CreateChunk(Vector3I chunkPos, float[] data)
	{
		chunkData[chunkPos] = data;
	}
	public void ChangeData(Vector3I chunkPos, int index, float value)
	{
		chunkData[chunkPos][index] = value;
	}
	public float GetDataIndex(Vector3I chunkPos, int index)
	{
		return chunkData[chunkPos][index];
	}
	public float GetDataPosLocal(Vector3I chunkPos, Vector3I pos)
	{
		return 0f;
	}
	public float GetDataPosGlobal(Vector3I pos)
	{
		return 0f;
	}

	public bool ChunkExists(Vector3I chunkPos)
	{
		return chunkData.ContainsKey(chunkPos);
	}

	public float[] GetChunk(Vector3I chunkPos)
	{
		return chunkData[chunkPos];
	}
/*
	public float ValueAt(Vector3I chunkPos, int index)
	{
		Dictionary<Vector3I, float[]> data = chunkManager.Get("chunk_data");
	}
	*/
}
