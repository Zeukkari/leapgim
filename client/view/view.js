var NewComponent = React.createClass({
  render: function() {
    return (
      <div>
        <title>Leapgim</title>
        <h1 style={{textAlign: 'center'}}>Leapgim</h1>
        <div id="audioNotitication" />
        <table style={{padding: 3, borderSpacing: 3}}>
          <colgroup>
            <col style={{width: 150}} />
            <col style={{width: '50x'}} />
          </colgroup>
          <tbody><tr>
              <th style={{width: 150}}>Refresh time: </th>
              <td style={{textIndent: 20, fontSize: 12}} colSpan={2}><div id="reload-status" /></td>
            </tr>
            <tr>
              <th>Hand confidence: </th>
              <td style={{textIndent: 20}} span={2}><meter value={0} max={100} optimum={90} low={50} min={0} id="meter" /></td>
            </tr>
            <tr>
              <td style={{padding: 15}} colSpan={3} />
            </tr>
            <tr>
              <th style={{textAlign: 'center'}} rowSpan={2}>Mouse: </th>
              <td style={{textIndent: 20}}>Left</td>
              <td><div id="left" className="stat">null</div></td>
            </tr>
            <tr>
              <td style={{textIndent: 20}}>Right</td>
              <td><div id="right" className="stat">null</div></td>
            </tr>
            <tr>
              <td style={{padding: 15}} colSpan={3} />
            </tr>
            <tr>
              <th style={{textAlign: 'center'}}>Elapsed time:</th>
              <td style={{textIndent: 20}} colSpan={2}><div id="timer" className="stat">null</div></td>
            </tr>
            <tr>
              <th style={{textAlign: 'center'}}>Hand visible:</th>
              <td style={{textIndent: 20}} colSpan={2}><div id="handVisible" className="stat">null</div></td>
            </tr>
          </tbody></table>
        &lt;
      </div>
    );
  }
});

ReactDOM.render(NewComponent, document.getElementById('example'));
