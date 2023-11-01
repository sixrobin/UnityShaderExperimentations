namespace RSLib
{
    using System.Collections.Generic;
    using System.Linq;

    public class RandomNumberGenerator
    {
        public RandomNumberGenerator()
        {
        }

        public RandomNumberGenerator(int seed)
        {
            Seed = seed;
        }

        public RandomNumberGenerator(GeneratorState state)
        {
            Seed = state.Seed;
            DeserializeGlobalState(state);
        }

        [System.Serializable]
        public struct RandomState
        {
            public string Id;
            public byte[] State;
        }

        [System.Serializable]
        public struct GeneratorState
        {
            public int Seed;
            public List<RandomState> RandomStates;
        }

        private readonly Dictionary<string, System.Random> _randomsLibrary = new Dictionary<string, System.Random>();

        public int Seed { get; }

        /// <summary>
        /// Retrieves the Random instance to use for a given calling object, based on its type.
        /// If no Random is found, a new instance is created on the fly and added to the randoms library.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <returns>Caller related random.</returns>
        private System.Random GetRandom(object caller)
        {
            string callerId = caller.GetType().Name;
            
            if (!_randomsLibrary.TryGetValue(callerId, out System.Random random))
            {
                random = Seed != 0 ? new System.Random(Seed) : new System.Random();
                _randomsLibrary.Add(callerId, random);
            }

            return random;
        }

        /// <summary>
        /// Initializes the seed for a given calling object, based on its type.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="seed">Random seed.</param>
        /// <param name="cleanup">Removes the already existing Random for the caller, if it has been found. Else, do nothing.</param>
        public void InitRandomSeed(object caller, int seed, bool cleanup = false)
        {
            string callerId = caller.GetType().Name;

            if (_randomsLibrary.ContainsKey(callerId))
            {
                if (!cleanup)
                    return;

                _randomsLibrary.Remove(callerId);
            }

            _randomsLibrary.Add(callerId, new System.Random(seed));
        }
        
        #region BOOLEAN
        /// <summary>
        /// Computes a random boolean.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <returns>True or false.</returns>
        public bool RandomBool(object caller)
        {
            return RandomRange(caller, 0f, 1f) > 0.5f;
        }
        #endregion // BOOLEAN

        #region FLOAT RANGE
        /// <summary>
        /// Computes a random float value between a minimum boundary and a maximum boundary.
        /// </summary>
        /// <param name="random">Random to use.</param>
        /// <param name="min">Minimum value (inclusive).</param>
        /// <param name="max">Maximum value (inclusive).</param>
        /// <returns>Random float value.</returns>
        private float RandomRange(System.Random random, float min, float max)
        {
            return (float)random.NextDouble() * (max - min) + min;
        }

        /// <summary>
        /// Computes a random float value between a minimum boundary and a maximum boundary.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="min">Minimum value (inclusive).</param>
        /// <param name="max">Maximum value (inclusive).</param>
        /// <returns>Random float value.</returns>
        public float RandomRange(object caller, float min, float max)
        {
            return RandomRange(GetRandom(caller), min, max);
        }
        
        /// <summary>
        /// Computes a random float value between a minimum boundary and a maximum boundary.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="range">Minimum and maximum values (both inclusive).</param>
        /// <returns>Random float value.</returns>
        public float RandomRange(object caller, UnityEngine.Vector2 range)
        {
            return RandomRange(caller, range.x, range.y);
        }
        
        /// <summary>
        /// Computes a random float value between 0f and 1f (both inclusive).
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <returns>Random float value between 0f and 1f.</returns>
        public float RandomValue(object caller)
        {
            return RandomRange(caller, 0f, 1f);
        }
        #endregion // FLOAT RANGE

        #region INT RANGE
        /// <summary>
        /// Computes a random int value between a minimum boundary and a maximum boundary.
        /// </summary>
        /// <param name="random">Random to use.</param>
        /// <param name="min">Minimum value (inclusive).</param>
        /// <param name="max">Maximum value (exclusive).</param>
        /// <returns>Random int value.</returns>
        private int RandomRange(System.Random random, int min, int max)
        {
            return random.Next(min, max);
        }

        /// <summary>
        /// Computes a random int value between a minimum boundary and a maximum boundary.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="min">Minimum value (inclusive).</param>
        /// <param name="max">Maximum value (exclusive).</param>
        /// <returns>Random int value.</returns>
        public int RandomRange(object caller, int min, int max)
        {
            return RandomRange(GetRandom(caller), min, max);
        }
        
        /// <summary>
        /// Computes a random int value between a minimum boundary and a maximum boundary.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="range">Minimum and maximum values (minimum is inclusive, maximum is exclusive).</param>
        /// <returns>Random int value.</returns>
        public int RandomRange(object caller, UnityEngine.Vector2Int range)
        {
            return RandomRange(caller, range.x, range.y);
        }
        #endregion // INT RANGE

        #region COLLECTIONS
        /// <summary>
        /// Gets a random element from a list.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="list">List to pick a random element in.</param>
        /// <returns>Random list element.</returns>
        private T RandomElement<T>(object caller, IReadOnlyList<T> list)
        {
            return list[RandomRange(caller, 0, list.Count)];
        }
        
        /// <summary>
        /// Gets a random element from an IEnumerable.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="enumerable">IEnumerable to pick a random element in.</param>
        /// <returns>Random IEnumerable element.</returns>
        public T RandomElement<T>(object caller, IEnumerable<T> enumerable)
        {
            List<T> list = enumerable.ToList();
            return RandomElement(caller, list);
        }
        
        /// <summary>
        /// Shuffles an IEnumerable.
        /// Result is returned a new IEnumerable object, original is not modified.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <param name="enumerable">IEnumerable to shuffle.</param>
        /// <typeparam name="T">Shuffled collection as a new object.</typeparam>
        /// <returns></returns>
        public IEnumerable<T> Shuffle<T>(object caller, IEnumerable<T> enumerable)
        {
            System.Random random = GetRandom(caller);
            return enumerable.Select(o => o).OrderBy(o => random.Next());
        }
        #endregion // COLLECTIONS

        #region SERIALIZATION
        /// <summary>
        /// Serializes the random state for a given calling object.
        /// </summary>
        /// <param name="random">Random to serialize.</param>
        /// <returns>Serialized random state.</returns>
        private byte[] SerializeRandom(System.Random random)
        {
            using (System.IO.MemoryStream memoryStream = new System.IO.MemoryStream())
            {
                new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter().Serialize(memoryStream, random);
                return memoryStream.ToArray();
            }
        }
        
        /// <summary>
        /// Serializes the random state for a given calling object.
        /// Can return null if calling object has no related random generator.
        /// </summary>
        /// <param name="caller">Calling object, which type will be used.</param>
        /// <returns>Serialized random state or null if calling object has no related random generator.</returns>
        public byte[] SerializeRandom(object caller)
        {
            string callerId = caller.GetType().Name;
            return _randomsLibrary.ContainsKey(callerId) ? SerializeRandom(GetRandom(caller)) : null;
        }

        /// <summary>
        /// Serializes all the generators states, as a list of generator states.
        /// Each generator state corresponds to an object type and its random state.
        /// </summary>
        /// <returns>Serialized global random number generator state.</returns>
        public GeneratorState SerializeGlobalState()
        {
            List<RandomState> randomStates = new List<RandomState>();
            foreach (KeyValuePair<string, System.Random> random in _randomsLibrary)
            {
                randomStates.Add(new RandomState()
                {
                    Id = random.Key,
                    State = SerializeRandom(random.Value)
                });
            }

            return new GeneratorState()
            {
                Seed = Seed,
                RandomStates = randomStates
            };
        }
        
        /// <summary>
        /// Deserializes the generators states, using a list of generator states as parameter.
        /// </summary>
        /// <param name="globalState">Serialized state.</param>
        /// <returns>True if deserialization was successful, else false.</returns>
        public bool DeserializeGlobalState(GeneratorState globalState)
        {
            try
            {
                foreach (RandomState generatorState in globalState.RandomStates)
                {
                    using (System.IO.MemoryStream memoryStream = new System.IO.MemoryStream(generatorState.State))
                    {
                        System.Runtime.Serialization.Formatters.Binary.BinaryFormatter formatter = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
                        System.Random deserializedRandom = formatter.Deserialize(memoryStream) as System.Random;
                        _randomsLibrary.Add(generatorState.Id, deserializedRandom);
                    }
                }

                return true;
            }
            catch (System.Exception e)
            {
                UnityEngine.Debug.LogError($"An error occured while deserializing global random number generator state! Exception: {e}");
                return false;
            }
        }
        #endregion // SERIALIZATION
    }
}
