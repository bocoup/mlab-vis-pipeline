package mlab.dataviz.entities;

import java.io.IOException;
import java.sql.SQLException;

import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.FullEntity;
import com.google.cloud.datastore.IncompleteKey;
import com.google.cloud.datastore.Datastore;
import com.google.cloud.datastore.DatastoreOptions;
import com.google.cloud.datastore.KeyFactory;
import com.google.cloud.datastore.Key;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson.JacksonFactory;

public class BTPipelineRunDatastore implements BTPipelineRunDao {

    private static final String KIND = "viz_pipeline_bt";

    private Datastore datastore;
    private KeyFactory keyFactory;
    
    /**
     * Creates a new bigtable pipeline run object
     * @throws IOException
     */
    public BTPipelineRunDatastore() throws IOException {
        HttpTransport transport = new NetHttpTransport();
        JsonFactory jsonFactory = new JacksonFactory();
        GoogleCredential credential = GoogleCredential.getApplicationDefault(transport, jsonFactory);

        DatastoreOptions options = DatastoreOptions.newBuilder().setNamespace("mlab-vis-pipeline").build();

        datastore = options.getService();
        keyFactory = datastore.newKeyFactory().setKind(KIND);
    }

    /**
     * Converts an entity to a bigtable pipeline run object.
     * @param entity DB entity
     * @return BTPipelineRun object
     */
    public BTPipelineRun entityToBTPipelineRun(Entity entity) {
        return new BTPipelineRun.Builder()
                .run_end_date(entity.getString(BTPipelineRun.RUN_END_DATE))
                .run_start_date(entity.getString(BTPipelineRun.RUN_START_DATE))
                .status(entity.getString(BTPipelineRun.STATUS))
                .id(entity.getKey().getId())
                .build();
    }

    /**
     * Create a new database entry from a BTPipelineRun object
     * @param bpr A BTPipelineRun object
     * @return id for created object. 
     */
	@Override
	public Long createBTPipelineRunEntity(BTPipelineRun bpr) throws SQLException {
		IncompleteKey incompleteKey = keyFactory.newKey();
        Key key = datastore.allocateId(incompleteKey);

        FullEntity<Key> btPipelineRunShellEntity = Entity.newBuilder(key)
                .set(BTPipelineRun.RUN_START_DATE, bpr.getRunStartDate())
                .set(BTPipelineRun.RUN_END_DATE, bpr.getRunEndDate())
                .set(BTPipelineRun.STATUS, BTPipelineRun.STATUS_RUNNING).build();

        Entity btPipelineRunEntity = datastore.add(btPipelineRunShellEntity);
        return btPipelineRunEntity.getKey().getId();
	}

	
	/**
	 * Fetches a bigtable pipeline run entity from datastore
	 * @param id 
	 * @return bpr BTPipelineRun object
	 */
	@Override
	public BTPipelineRun getBTPipelineRunEntity(Long id) throws SQLException {
		Entity btPipelineRunEntity = datastore.get(keyFactory.newKey(id));
        return entityToBTPipelineRun(btPipelineRunEntity);
	}

	/**
	 * Update a run in datastore
	 * @param btPipelineRun BTPipelineRun object
	 */
	@Override
	public void updateBTPipelineRunEntity(BTPipelineRun btPipelineRun) throws SQLException {
        Key key = keyFactory.newKey(btPipelineRun.getId());
        Entity btPipelineEntity = Entity.newBuilder(key)
                .set(BTPipelineRun.RUN_START_DATE, btPipelineRun.getRunStartDate())
                .set(BTPipelineRun.RUN_END_DATE, btPipelineRun.getRunEndDate())
                .set(BTPipelineRun.STATUS, BTPipelineRun.STATUS_RUNNING).build();
        datastore.update(btPipelineEntity);
	}

	/**
	 * Mark a run complete
	 * @param id of a run
	 */
	@Override
	public void markBTPipelineRunComplete(long id) throws SQLException {
		Key key = keyFactory.newKey(id);
        BTPipelineRun vpr = getBTPipelineRunEntity(id);
        Entity btPipelineRunEntity = Entity.newBuilder(key)
                .set(BTPipelineRun.RUN_START_DATE, vpr.getRunStartDate())
                .set(BTPipelineRun.RUN_END_DATE, vpr.getRunEndDate())
                .set(BTPipelineRun.STATUS, BTPipelineRun.STATUS_DONE).build();
        datastore.update(btPipelineRunEntity);
	}
}